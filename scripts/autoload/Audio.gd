extends Node
# Audio del juego. Los demas solo llaman:
#   Audio.sfx("katana")     -> res://audio/sfx/sfx_katana (.wav, .ogg o .mp3)
#   Audio.musica("run")     -> res://audio/musica/mus_run.ogg
#   Audio.musica("aldea")   -> capas mus_aldea_capa1..6.ogg
#   Audio.subir_capa(n)     -> en la aldea, suenan las capas 1 a n
#   Audio.musica("menu")    -> res://audio/musica/mus_menu.ogg (si no existe, la de la aldea)
#   Audio.musica("jefe")    -> cualquier otro nombre: mus_jefe en loop (si no existe, sigue la que suena)
#   Audio.jingle("derrota") -> mus_derrota una sola vez, cortando la musica (victoria, derrota...)
# Todos los botones del juego suenan solos al pasar el mouse o el teclado por
# encima (sfx_hover): nadie tiene que conectar nada en sus escenas.
# El clic sigue siendo Audio.sfx("boton") en cada escena, como hasta ahora.
# Si un archivo todavia no existe, no suena y no da error.

const RUTA_SFX := "res://audio/sfx/sfx_%s"
const RUTA_MUSICA := "res://audio/musica/mus_%s"
const EXTENSIONES := ["wav", "ogg", "mp3"] # sirve cualquiera de las tres
const CAPAS_ALDEA := 6
const CANALES_SFX := 8 # cuantos efectos pueden sonar a la vez
const SILENCIO := -80.0
const VOLUMEN_MUSICA := -8.0
const VOLUMEN_SFX := -4.0
const VOLUMEN_HOVER := -14.0 # el sonido de pasar el mouse va bajito

var canales: Array[AudioStreamPlayer] = []
var siguiente := 0
var capas: Array[AudioStreamPlayer] = []
var tema_run: AudioStreamPlayer
var tema_menu: AudioStreamPlayer
var cache := {}
var tema_extra: AudioStreamPlayer # jefe y cualquier otra musica en loop
var tema_jingle: AudioStreamPlayer # musiquitas cortas de una vez

const ARCHIVO_OPCIONES := "user://opciones.cfg"

# Volumen de 0.0 a 1.0 por bus. Lo cambian las barras de la pausa y del menu de sonido.
# Se guarda, asi al volver a abrir el juego queda como lo dejaste.
func poner_volumen(bus: String, valor: float, guardar := true) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(valor, 0.0001)))
	if guardar:
		var cfg := ConfigFile.new()
		cfg.load(ARCHIVO_OPCIONES)
		cfg.set_value("volumen", bus, valor)
		cfg.save(ARCHIVO_OPCIONES)

func _cargar_volumenes() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARCHIVO_OPCIONES) != OK:
		return
	for bus in ["Musica", "Efectos"]:
		if cfg.has_section_key("volumen", bus):
			poner_volumen(bus, float(cfg.get_value("volumen", bus)), false)

func volumen(bus: String) -> float:
	var i := AudioServer.get_bus_index(bus)
	return db_to_linear(AudioServer.get_bus_volume_db(i)) if i >= 0 else 1.0

func _crear_bus(nombre: String) -> void:
	if AudioServer.get_bus_index(nombre) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, nombre)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # suena aunque el juego este en pausa
	_crear_bus("Musica")
	_crear_bus("Efectos")
	_cargar_volumenes()
	for i in CANALES_SFX:
		var p := AudioStreamPlayer.new()
		p.volume_db = VOLUMEN_SFX
		p.bus = "Efectos"
		add_child(p)
		canales.append(p)
	for i in CAPAS_ALDEA:
		var c := _reproductor_musica(_cargar(RUTA_MUSICA % ("aldea_capa%d" % (i + 1)), true), SILENCIO)
		capas.append(c)
	tema_run = _reproductor_musica(_cargar(RUTA_MUSICA % "run", true), VOLUMEN_MUSICA)
	var pista_menu := _cargar(RUTA_MUSICA % "menu", true)
	if pista_menu == null:
		pista_menu = _cargar(RUTA_MUSICA % "aldea_capa1", true)
	tema_menu = _reproductor_musica(pista_menu, VOLUMEN_MUSICA)
	tema_extra = _reproductor_musica(null, VOLUMEN_MUSICA)
	tema_jingle = _reproductor_musica(null, VOLUMEN_MUSICA)
	# Cada boton que aparezca en cualquier escena recibe sus sonidos
	get_tree().node_added.connect(_on_nodo_agregado)

# La musica va en modo STREAM: en la Web el modo por defecto ("sample") no la
# hace sonar con nuestros buses creados por codigo ni con los cambios de volumen.
# Los efectos se quedan en el modo por defecto (suenan bien y sin retraso).
func _reproductor_musica(pista: AudioStream, volumen_inicial: float) -> AudioStreamPlayer:
	var r := AudioStreamPlayer.new()
	r.stream = pista
	r.volume_db = volumen_inicial
	r.bus = "Musica"
	r.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(r)
	return r

func _on_nodo_agregado(nodo: Node) -> void:
	if nodo is BaseButton:
		nodo.mouse_entered.connect(_sonar_hover.bind(nodo))
		nodo.focus_entered.connect(_sonar_hover.bind(nodo))

func _sonar_hover(boton: BaseButton) -> void:
	if not boton.disabled and boton.is_visible_in_tree():
		sfx("hover", VOLUMEN_HOVER)

# "base" va sin extension: prueba .wav, .ogg y .mp3 en ese orden.
func _cargar(base: String, en_loop := false) -> AudioStream:
	if cache.has(base):
		return cache[base]
	var s: AudioStream = null
	for ext: String in EXTENSIONES:
		var ruta: String = base + "." + ext
		if ResourceLoader.exists(ruta):
			s = load(ruta)
			break
	if en_loop and (s is AudioStreamOggVorbis or s is AudioStreamMP3):
		s.loop = true
	cache[base] = s
	return s

func sfx(nombre: String, volumen := VOLUMEN_SFX) -> void:
	var s := _cargar(RUTA_SFX % nombre)
	if s == null:
		return
	var p := canales[siguiente]
	siguiente = (siguiente + 1) % CANALES_SFX
	p.stream = s
	p.volume_db = volumen
	p.pitch_scale = randf_range(0.95, 1.05) # que no suene identico cada vez
	p.play()

func musica(nombre: String) -> void:
	if not nombre in ["menu", "run", "aldea"]:
		var pista := _cargar(RUTA_MUSICA % nombre, true)
		if pista == null:
			return # no hay archivo: que siga sonando lo que estaba
		parar_musica()
		tema_extra.stream = pista
		tema_extra.play()
		return
	parar_musica()
	match nombre:
		"menu":
			if tema_menu.stream:
				tema_menu.play()
		"run":
			if tema_run.stream:
				tema_run.play()
		"aldea":
			for c in capas:
				if c.stream:
					c.volume_db = SILENCIO
					c.play() # todas arrancan juntas para quedar sincronizadas
			subir_capa(1 + Estado.edificios.size())

func subir_capa(n: int) -> void:
	for i in capas.size():
		var objetivo := VOLUMEN_MUSICA if i < n else SILENCIO
		create_tween().tween_property(capas[i], "volume_db", objetivo, 1.5)

# Una musiquita corta (sin loop): corta la musica y suena una vez.
func jingle(nombre: String) -> void:
	var base := RUTA_MUSICA % nombre
	var pista: AudioStream = null
	for ext: String in EXTENSIONES:
		if ResourceLoader.exists(base + "." + ext):
			pista = load(base + "." + ext).duplicate()
			break
	if pista == null:
		return
	if pista is AudioStreamOggVorbis or pista is AudioStreamMP3:
		pista.loop = false
	elif pista is AudioStreamWAV:
		pista.loop_mode = AudioStreamWAV.LOOP_DISABLED
	parar_musica()
	tema_jingle.stream = pista
	tema_jingle.play()

func parar_musica() -> void:
	tema_run.stop()
	tema_menu.stop()
	tema_extra.stop() # el jingle no se corta: es corto y se mezcla con la entrada a la aldea
	for c in capas:
		c.stop()
