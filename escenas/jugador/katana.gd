extends Area2D
# Katana (Ronin): corte al frente cada cierto tiempo.

const RECARGA_MINIMA := 0.5 # nunca ataca mas rapido que esto
const ALCANCE_APUNTAR := 70.0 # apunta sola al yokai mas cercano dentro de esta distancia

const ESCALA_INICIAL := 1.15 # un poco mas grande desde el inicio
const ESCALA_MAXIMA := 1.8 # tope: nunca se vuelve gigante

var nivel := 1
var dano := 7 # antes 5 (+2 por nivel): con kunais ya no valia la pena subirla
var heroe
var mostrando := false

@onready var timer: Timer = $Timer

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	scale = Vector2.ONE * ESCALA_INICIAL
	timer.timeout.connect(_atacar)

func _physics_process(_delta: float) -> void:
	if heroe == null or mostrando:
		return # durante el corte la direccion queda fija (antes se podia girar y pegar en 360)
	var objetivo := yokai_mas_cercano()
	if objetivo:
		rotation = global_position.direction_to(objetivo.global_position).angle()
	else:
		rotation = heroe.direccion.angle() # sin yokais cerca: hacia donde camina

func yokai_mas_cercano() -> Node2D:
	var mejor: Node2D = null
	var mejor_distancia := ALCANCE_APUNTAR * scale.x
	for e in Yokai.todos(get_tree()):
		var d := global_position.distance_to(e.global_position)
		if d < mejor_distancia:
			mejor = e
			mejor_distancia = d
	return mejor

func _atacar() -> void:
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos"):
			cuerpo.recibir_dano(int(round(dano * heroe.poder)))
	Audio.sfx("katana")
	mostrando = true
	sentido = -sentido # un corte de arriba a abajo, el siguiente de abajo a arriba
	var t := create_tween()
	t.tween_method(_poner_progreso, 0.0, 1.0, DURACION_CORTE)
	t.tween_callback(_ocultar)

func _poner_progreso(p: float) -> void:
	progreso = p
	queue_redraw()

func _ocultar() -> void:
	mostrando = false
	queue_redraw()

# El corte: animacion pixel art de 6 cuadros (arte/ui/corte_katana.png, 28x44 cada uno):
# aparece fino, se abre en media luna blanca y azul, y se deshace en rayas.
# Un corte sale normal y el siguiente volteado (de arriba a abajo / de abajo a arriba).
const DURACION_CORTE := 0.24
const HOJA := preload("res://arte/ui/corte_katana.png")
const CUADROS_CORTE := 6
const ANCHO_CORTE := 28
const ALTO_CORTE := 44
const ORIGEN_CORTE := Vector2(2, 22) # el punto del dibujo que va sobre la katana
const CENTRO_CORTE := Vector2(4, 0)
var progreso := 0.0
var sentido := 1.0

func _draw() -> void:
	if not mostrando:
		return
	var cuadro := mini(int(progreso * CUADROS_CORTE), CUADROS_CORTE - 1)
	var fuente := Rect2(cuadro * ANCHO_CORTE, 0, ANCHO_CORTE, ALTO_CORTE)
	draw_set_transform(CENTRO_CORTE, 0.0, Vector2(1.0, sentido))
	draw_texture_rect_region(HOJA, Rect2(-ORIGEN_CORTE, Vector2(ANCHO_CORTE, ALTO_CORTE)), fuente)
	draw_set_transform(Vector2.ZERO)

# La llama el heroe cuando eligen la katana en el menu de mejoras.
# Crece en linea recta hasta el tope: al nivel 8 llega a 1.8 (antes 1.7) y pega 28 (antes 19).
func subir_nivel() -> void:
	nivel += 1
	dano += 3
	scale = Vector2.ONE * minf(ESCALA_MAXIMA, ESCALA_INICIAL + 0.1 * (nivel - 1))
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time - 0.04)
