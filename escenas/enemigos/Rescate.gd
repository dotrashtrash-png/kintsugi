extends Area2D
# Rescate: un aldeano atrapado por un sello de los yokais.
# Quedate 3 s dentro del circulo: el sello morado se vuelve dorado y el aldeano queda libre.
# Cada rescate es un aldeano distinto (6 variantes en arte/aldea/aldeanos.png).

const TIEMPO_PARA_LIBERAR := 3.0
const ORO_POR_RESCATE := 2
const KASAS_EMBOSCADA := 6 # al empezar a liberar, salen paraguas alrededor
const RUTA_ALDEANOS := "res://arte/aldea/aldeanos.png" # 64x96: 6 aldeanos, 4 cuadros cada uno
const RUTA_ALDEANO := "res://arte/aldea/aldeano.png" # respaldo: un solo aldeano
const RADIO := 28.0
const MORADO := Color("8a63b8")
const ORO := Color("e8b04a")

var heroe_dentro := false
var progreso := 0.0
var liberado := false
var emboscada_hecha := false
var reloj := 0.0
var dibujo: Sprite2D
var aviso: Label


func _ready() -> void:
	add_to_group("rescates")
	$Niebla.visible = false # el sello se dibuja con codigo (_draw)
	$Barra.visible = false
	poner_dibujo()
	poner_aviso()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# el sello se dibuja en el piso: el Rescate va despues del mapa en el arbol, asi queda encima del suelo


func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = true
		if not emboscada_hecha:
			emboscada_hecha = true
			emboscada.call_deferred() # no se puede crear cuerpos en medio de la fisica


func _on_body_exited(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = false


func _process(delta: float) -> void:
	if liberado:
		return
	reloj += delta
	if heroe_dentro:
		progreso += delta
	else:
		progreso = maxf(0.0, progreso - delta * 0.5) # si sales, el sello vuelve despacio
	# el aldeano tiembla mientras esta atrapado
	if dibujo:
		dibujo.position.x = roundf(sin(reloj * 30.0) * 0.6) if progreso < TIEMPO_PARA_LIBERAR else 0.0
	if aviso:
		aviso.visible = not heroe_dentro
		aviso.position.y = -30.0 - absf(sin(reloj * 4.0)) * 3.0
	queue_redraw()
	if progreso >= TIEMPO_PARA_LIBERAR:
		liberar()


# El sello: circulo morado que gira y se va llenando de oro
func _draw() -> void:
	var avance := clampf(progreso / TIEMPO_PARA_LIBERAR, 0.0, 1.0)
	var color := MORADO.lerp(ORO, avance)
	draw_circle(Vector2.ZERO, RADIO, Color(color, 0.12 + 0.06 * sin(reloj * 3.0)))
	draw_arc(Vector2.ZERO, RADIO, 0.0, TAU, 40, Color(color, 0.7), 1.0)
	# cuatro marcas del sello que giran
	for i in 4:
		var a := reloj * 0.8 + TAU * i / 4.0
		draw_arc(Vector2.ZERO, RADIO - 4.0, a, a + 0.6, 6, Color(color, 0.9), 1.0)
	# progreso: arco dorado que se completa
	if avance > 0.0:
		draw_arc(Vector2.ZERO, RADIO + 3.0, -PI / 2.0, -PI / 2.0 + TAU * avance, 40, ORO, 2.0)


func liberar() -> void:
	liberado = true
	Audio.sfx("rescate")
	var run = get_tree().get_first_node_in_group("run")
	if run:
		run.agregar_aldeano()
		run.agregar_material("oro", ORO_POR_RESCATE)
	celebrar()


# Destello dorado, el aldeano salta y aparece "¡Rescatado!"
func celebrar() -> void:
	set_process(false)
	if aviso:
		aviso.visible = false
	var texto := Label.new()
	texto.text = "¡Rescatado! +%d oro" % ORO_POR_RESCATE
	texto.add_theme_font_size_override("font_size", 16)
	texto.add_theme_color_override("font_color", ORO)
	texto.add_theme_color_override("font_outline_color", Color("1b1a2e"))
	texto.add_theme_constant_override("outline_size", 4)
	texto.scale = Vector2(0.5, 0.5)
	texto.position = Vector2(-40, -40)
	add_child(texto)
	var t := create_tween().set_parallel()
	t.tween_property(texto, "position:y", -58.0, 0.9)
	t.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.6)
	if dibujo:
		t.tween_property(dibujo, "position:y", -10.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var anillo := create_tween()
	anillo.tween_method(func(r: float) -> void:
		progreso = TIEMPO_PARA_LIBERAR
		reloj = r
		queue_redraw(), 0.0, 3.0, 0.5)
	t.chain().tween_callback(queue_free)


# Un aldeano distinto en cada rescate
func poner_dibujo() -> void:
	var ruta := RUTA_ALDEANOS if ResourceLoader.exists(RUTA_ALDEANOS) else RUTA_ALDEANO
	if not ResourceLoader.exists(ruta):
		return
	dibujo = Sprite2D.new()
	dibujo.texture = load(ruta)
	dibujo.hframes = 4
	dibujo.vframes = int(dibujo.texture.get_height() / 16.0)
	dibujo.frame = randi() % dibujo.vframes * 4 # cuadro de frente de un aldeano al azar
	dibujo.z_index = 1
	add_child(dibujo)
	$Aldeano.visible = false


# "!" dorado que salta encima del aldeano para que se vea de lejos
func poner_aviso() -> void:
	aviso = Label.new()
	aviso.text = "!"
	aviso.add_theme_font_size_override("font_size", 16)
	aviso.add_theme_color_override("font_color", ORO)
	aviso.add_theme_color_override("font_outline_color", Color("1b1a2e"))
	aviso.add_theme_constant_override("outline_size", 4)
	aviso.scale = Vector2(0.5, 0.5)
	aviso.position = Vector2(-2, -34)
	aviso.z_index = 2
	add_child(aviso)


# Los yokais no dejan rescatar tranquilo: aparece un circulo de Kasas
func emboscada() -> void:
	var spawner = get_parent()
	if spawner == null or not spawner.has_method("crear"):
		return
	for i in KASAS_EMBOSCADA:
		var punto: Vector2 = global_position + Vector2.RIGHT.rotated(TAU * i / KASAS_EMBOSCADA) * 110.0
		spawner.crear(spawner.escena_kasa, punto)
