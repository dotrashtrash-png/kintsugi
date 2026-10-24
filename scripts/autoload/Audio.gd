extends Node
# Audio del juego. Los demas solo llaman:
#   Audio.sfx("katana")     -> res://audio/sfx/sfx_katana.wav
#   Audio.musica("run")     -> res://audio/musica/mus_run.ogg
#   Audio.musica("aldea")   -> capas mus_aldea_capa1..6.ogg
#   Audio.subir_capa(n)     -> en la aldea, suenan las capas 1 a n
#   Audio.musica("menu")    -> res://audio/musica/mus_menu.ogg (si no existe, la de la aldea)
# Todos los botones del juego suenan solos al pasar el mouse o el teclado por
# encima (sfx_hover): nadie tiene que conectar nada en sus escenas.
# El clic sigue siendo Audio.sfx("boton") en cada escena, como hasta ahora.
# Si un archivo todavia no existe, no suena y no da error.

const RUTA_SFX := "res://audio/sfx/sfx_%s.wav"
const RUTA_MUSICA := "res://audio/musica/mus_%s.ogg"
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

# Volumen de 0.0 a 1.0 por bus. Lo cambia la pausa con sus barras.
func poner_volumen(bus: String, valor: float) -> void:
	var i := AudioServer.get_bus_index(bus)
	if i >= 0:
		AudioServer.set_bus_volume_db(i, linear_to_db(maxf(valor, 0.0001)))

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
	for i in CANALES_SFX:
		var p := AudioStreamPlayer.new()
		p.volume_db = VOLUMEN_SFX
		p.bus = "Efectos"
		add_child(p)
		canales.append(p)
	for i in CAPAS_ALDEA:
		var c := AudioStreamPlayer.new()
		c.stream = _cargar(RUTA_MUSICA % ("aldea_capa%d" % (i + 1)), true)
		c.volume_db = SILENCIO
		c.bus = "Musica"
		add_child(c)
		capas.append(c)
	tema_run = AudioStreamPlayer.new()
	tema_run.stream = _cargar(RUTA_MUSICA % "run", true)
	tema_run.volume_db = VOLUMEN_MUSICA
	tema_run.bus = "Musica"
	add_child(tema_run)
	tema_menu = AudioStreamPlayer.new()
	tema_menu.stream = _cargar(RUTA_MUSICA % "menu", true)
	if tema_menu.stream == null:
		tema_menu.stream = _cargar(RUTA_MUSICA % "aldea_capa1", true)
	tema_menu.volume_db = VOLUMEN_MUSICA
	tema_menu.bus = "Musica"
	add_child(tema_menu)
	# Cada boton que aparezca en cualquier escena recibe sus sonidos
	get_tree().node_added.connect(_on_nodo_agregado)

func _on_nodo_agregado(nodo: Node) -> void:
	if nodo is BaseButton:
		nodo.mouse_entered.connect(_sonar_hover.bind(nodo))
		nodo.focus_entered.connect(_sonar_hover.bind(nodo))

func _sonar_hover(boton: BaseButton) -> void:
	if not boton.disabled and boton.is_visible_in_tree():
		sfx("hover", VOLUMEN_HOVER)

func _cargar(ruta: String, en_loop := false) -> AudioStream:
	if cache.has(ruta):
		return cache[ruta]
	var s: AudioStream = null
	if ResourceLoader.exists(ruta):
		s = load(ruta)
		if en_loop and s is AudioStreamOggVorbis:
			s.loop = true
	cache[ruta] = s
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

func parar_musica() -> void:
	tema_run.stop()
	tema_menu.stop()
	for c in capas:
		c.stop()
