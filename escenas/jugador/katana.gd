extends Area2D

var nivel := 1
var dano := 5
var heroe

@onready var visual: ColorRect = $Visual
@onready var timer: Timer = $Timer

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	timer.timeout.connect(_atacar)
	visual.visible = false

func _physics_process(_delta: float) -> void:
	if heroe:
		rotation = heroe.direccion.angle() # apunta hacia donde camina

func _atacar() -> void:
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos"):
			cuerpo.recibir_dano(dano)
	Audio.sfx("katana")
	visual.visible = true
	await get_tree().create_timer(0.1).timeout
	visual.visible = false

# La llama el heroe cuando eligen la katana en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	dano += 3
	scale *= 1.15 # mas alcance y angulo
