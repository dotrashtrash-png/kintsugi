extends Node
# Audio del juego. Los demas solo llaman:
#   Audio.sfx("katana")     -> res://audio/sfx/sfx_katana.wav
#   Audio.musica("run")     -> res://audio/musica/mus_run.ogg
#   Audio.musica("aldea")   -> capas mus_aldea_capa1..6.ogg
#   Audio.subir_capa(n)     -> en la aldea, suenan las capas 1 a n
# Si un archivo todavia no existe, no suena y no da error.

const RUTA_SFX := "res://audio/sfx/sfx_%s.wav"
const RUTA_MUSICA := "res://audio/musica/mus_%s.ogg"
const CAPAS_ALDEA := 6
const CANALES_SFX := 8 # cuantos efectos pueden sonar a la vez
const SILENCIO := -80.0
const VOLUMEN_MUSICA := -8.0
const VOLUMEN_SFX := -4.0

var canales: Array[AudioStreamPlayer] = []
var siguiente := 0
var capas: Array[AudioStreamPlayer] = []
var tema_run: AudioStreamPlayer
var cache := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # suena aunque el juego este en pausa
	for i in CANALES_SFX:
		var p := AudioStreamPlayer.new()
		p.volume_db = VOLUMEN_SFX
		add_child(p)
		canales.append(p)
	for i in CAPAS_ALDEA:
		var c := AudioStreamPlayer.new()
		c.stream = _cargar(RUTA_MUSICA % ("aldea_capa%d" % (i + 1)), true)
		c.volume_db = SILENCIO
		add_child(c)
		capas.append(c)
	tema_run = AudioStreamPlayer.new()
	tema_run.stream = _cargar(RUTA_MUSICA % "run", true)
	tema_run.volume_db = VOLUMEN_MUSICA
	add_child(tema_run)

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

func sfx(nombre: String) -> void:
	var s := _cargar(RUTA_SFX % nombre)
	if s == null:
		return
	var p := canales[siguiente]
	siguiente = (siguiente + 1) % CANALES_SFX
	p.stream = s
	p.pitch_scale = randf_range(0.95, 1.05) # que no suene identico cada vez
	p.play()

func musica(nombre: String) -> void:
	parar_musica()
	match nombre:
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
	for c in capas:
		c.stop()
