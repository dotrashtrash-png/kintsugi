extends Area2D

var nivel := 1
var dano := 5
var heroe
var mostrando := false

@onready var timer: Timer = $Timer

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	timer.timeout.connect(_atacar)

func _physics_process(_delta: float) -> void:
	if heroe:
		rotation = heroe.direccion.angle() # apunta hacia donde camina

func _atacar() -> void:
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos"):
			cuerpo.recibir_dano(dano)
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

# La llama el heroe cuando eligen la katana en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	dano += 3
	scale *= 1.15 # mas alcance
