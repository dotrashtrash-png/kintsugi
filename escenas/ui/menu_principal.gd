extends Control

# Menu principal: la primera pantalla del juego.
# Fondo animado (el cuenco de kintsugi), logo, y tres botones: Jugar, Como jugar, Creditos.
# "Jugar" lleva a la intro la primera vez y despues directo a la aldea.

const RUTA_ALDEA := "res://escenas/base/Aldea.tscn"
const RUTA_INTRO := "res://escenas/ui/Intro.tscn"
const RUTA_LOGO := "res://arte/ui/logo.png" # cuando Matta lo suba, reemplaza al texto
const FONDO := preload("res://arte/ui/menu_fondo.png") # cuadricula de 8 columnas de 384x216
const ANCHO := 384
const ALTO := 216
const COLUMNAS := 8

const COMO_JUGAR := "[b]Moverse:[/b] WASD o flechas
[b]Atacar:[/b] tus armas atacan solas
[b]Subir de nivel:[/b] recoge las luces doradas y elige una mejora
[b]Rescatar aldeanos:[/b] quédate 3 segundos a su lado (¡cuidado, los yokais te rodean!)
[b]Sobrevive 6 minutos[/b] y vuelves a la aldea con todo lo que juntaste. Si caes, traes la mitad.
[b]En la aldea:[/b] repara edificios con madera, tejas y oro. Cada uno trae algo nuevo.
[b]Esc o P:[/b] pausa"

var atlas := AtlasTexture.new()
var cuadro := 0
var total := 0


func _ready() -> void:
	$Botones/BotonJugar.pressed.connect(_on_jugar)
	$Botones/BotonComoJugar.pressed.connect(_on_como_jugar)
	$Botones/BotonCreditos.pressed.connect(_on_creditos)
	$Ventana/Columna/BotonVolver.pressed.connect(_on_volver)
	# Boton de Sonido: copia del de Creditos (mismo estilo), sin sus conexiones
	var boton_sonido: Button = $Botones/BotonCreditos.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS)
	boton_sonido.name = "BotonSonido"
	boton_sonido.text = "Sonido"
	boton_sonido.pressed.connect(func() -> void: MenuSonido.abrir(self))
	$Botones.add_child(boton_sonido)
	# Con 4 botones la fila ya no cabia en su caja y quedaba corrida a la derecha:
	# se achican un poco y la caja se centra con el ancho justo.
	var ancho_total := 0.0
	for b: Button in $Botones.get_children():
		b.custom_minimum_size.x = 160
		ancho_total += 160
	ancho_total += 18 * ($Botones.get_child_count() - 1)
	$Botones.offset_left = -ancho_total / 2.0
	$Botones.offset_right = ancho_total / 2.0
	$Ventana.visible = false
	animar_fondo()
	poner_logo()
	entrada()
	Audio.musica("menu")
	$Botones/BotonJugar.grab_focus() # se puede jugar con Enter, sin mouse


# ---------- Fondo animado ----------

func animar_fondo() -> void:
	atlas.atlas = FONDO
	atlas.region = Rect2(0, 0, ANCHO, ALTO)
	$FondoImagen.texture = atlas
	total = COLUMNAS * int(FONDO.get_height() / ALTO)
	var reloj := Timer.new()
	reloj.wait_time = 0.125
	reloj.autostart = true
	add_child(reloj)
	reloj.timeout.connect(_siguiente_cuadro)


func _siguiente_cuadro() -> void:
	cuadro = (cuadro + 1) % total
	atlas.region = Rect2((cuadro % COLUMNAS) * ANCHO, floori(float(cuadro) / COLUMNAS) * ALTO, ANCHO, ALTO)


# ---------- Logo y entrada ----------

func poner_logo() -> void:
	if ResourceLoader.exists(RUTA_LOGO):
		$Logo.texture = load(RUTA_LOGO)
		$Logo.visible = true
		$Titulo.visible = false
	else:
		$Logo.visible = false


# El titulo aparece con un fundido, flota suave, y los botones llegan despues.
func entrada() -> void:
	var titulo: Control = $Logo if $Logo.visible else $Titulo
	for n in [titulo, $Subtitulo, $Botones]:
		n.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(titulo, "modulate:a", 1.0, 1.0)
	t.tween_property($Subtitulo, "modulate:a", 1.0, 0.5)
	t.tween_property($Botones, "modulate:a", 1.0, 0.4)
	var flotar := create_tween().set_loops()
	var y0: float = titulo.position.y
	flotar.tween_property(titulo, "position:y", y0 - 4.0, 1.6).set_trans(Tween.TRANS_SINE)
	flotar.tween_property(titulo, "position:y", y0, 1.6).set_trans(Tween.TRANS_SINE)


# ---------- Botones ----------

func _on_jugar() -> void:
	Audio.sfx("boton")
	var destino := RUTA_ALDEA
	if not Estado.vio_intro and ResourceLoader.exists(RUTA_INTRO):
		destino = RUTA_INTRO
	get_tree().change_scene_to_file(destino)


func _on_como_jugar() -> void:
	abrir_ventana("Cómo jugar", COMO_JUGAR)


func _on_creditos() -> void:
	abrir_ventana("Créditos", $Creditos.text)


func abrir_ventana(titulo: String, texto: String) -> void:
	Audio.sfx("boton")
	$Ventana/Columna/TituloVentana.text = titulo
	$Ventana/Columna/Texto.text = texto
	$Ventana.visible = true
	$Botones.visible = false
	$Ventana.scale = Vector2(0.9, 0.9)
	$Ventana.pivot_offset = $Ventana.size / 2.0
	create_tween().tween_property($Ventana, "scale", Vector2.ONE, 0.12)
	$Ventana/Columna/BotonVolver.grab_focus()


func _on_volver() -> void:
	Audio.sfx("boton")
	$Ventana.visible = false
	$Botones.visible = true
	$Botones/BotonJugar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if $Ventana.visible and event.is_action_pressed("ui_cancel"):
		_on_volver()
