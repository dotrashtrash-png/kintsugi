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
	queue_redraw()
	create_tween().tween_callback(_ocultar).set_delay(0.1)

func _ocultar() -> void:
	mostrando = false
	queue_redraw()

# Media luna blanca: el corte de la katana
func _draw() -> void:
	if not mostrando:
		return
	draw_arc(Vector2(4, 0), 18.0, -PI / 3.0, PI / 3.0, 16, Color(1, 1, 1, 0.9), 3.0)
	draw_arc(Vector2(4, 0), 14.0, -PI / 4.0, PI / 4.0, 12, Color(1, 1, 1, 0.45), 2.0)

# La llama el heroe cuando eligen la katana en el menu de mejoras.
# Crece en linea recta hasta el tope: al nivel 8 llega a 1.8 (antes 1.7) y pega 28 (antes 19).
func subir_nivel() -> void:
	nivel += 1
	dano += 3
	scale = Vector2.ONE * minf(ESCALA_MAXIMA, ESCALA_INICIAL + 0.1 * (nivel - 1))
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time - 0.04)
