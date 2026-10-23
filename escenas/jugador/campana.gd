extends Node2D
# Campana suzu (Miko): onda circular que crece, dana y empuja.

const RECARGA_MINIMA := 1.0 # nunca suena mas rapido que esto
const RADIO_MAXIMO := 80.0 # nunca cubre toda la pantalla

var nivel := 1
var dano := 3
var radio_max := 45.0
var empuje := 12.0
var duracion := 0.35 # lo que tarda la onda en crecer

var radio := 0.0
var golpeados: Array = []

@onready var timer: Timer = $Timer
@onready var heroe = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	timer.wait_time = 1.8
	timer.timeout.connect(_sonar)

func _sonar() -> void:
	Audio.sfx("campana")
	golpeados.clear()
	var tween := create_tween()
	tween.tween_property(self, "radio", radio_max, duracion).from(0.0)
	tween.tween_callback(_apagar)

func _apagar() -> void:
	radio = 0.0
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if radio <= 0.0:
		return
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if not is_instance_valid(enemigo) or enemigo in golpeados:
			continue
		if global_position.distance_to(enemigo.global_position) <= radio:
			golpeados.append(enemigo)
			if not enemigo.is_in_group("jefe"): # al Tengu no se le empuja
				var dir: Vector2 = global_position.direction_to(enemigo.global_position)
				enemigo.global_position += dir * empuje
			enemigo.recibir_dano(int(round(dano * heroe.poder)))
	queue_redraw()

func _draw() -> void:
	if radio > 0.0:
		draw_arc(Vector2.ZERO, radio, 0.0, TAU, 32, Color(1, 0.9, 0.5, 0.8), 2.0)

# La llama el heroe cuando eligen la campana en el menu de mejoras.
# Todo sube en linea recta y con tope: ya no cubre la pantalla ni suena sin parar.
func subir_nivel() -> void:
	nivel += 1
	dano += 2
	radio_max = minf(RADIO_MAXIMO, radio_max + 5.0)
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time - 0.1)
