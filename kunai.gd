extends Node2D
# Kunai (Kunoichi): lanza cuchillos hacia donde mira el heroe. Atraviesan yokais.
const CUCHILLO := preload("res://escenas/jugador/Cuchillo.tscn")
const ABANICO := 0.18 # radianes entre un cuchillo y el siguiente
var nivel := 1
var dano := 7
var cantidad := 1
var heroe
@onready var timer: Timer = $Timer

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	timer.timeout.connect(_lanzar)

func _lanzar() -> void:
	Audio.sfx("kunai")
	var base: Vector2 = heroe.direccion.normalized()
	for i in cantidad:
		var c = CUCHILLO.instantiate()
		# Si son varios, salen en abanico centrado
		c.direccion = base.rotated((i - (cantidad - 1) / 2.0) * ABANICO)
		c.dano = int(round(dano * heroe.poder))
		get_tree().current_scene.add_child(c)
		c.global_position = global_position

# La llama el heroe cuando eligen el kunai en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	dano += 2
	if nivel % 2 == 0:
		cantidad += 1 # un cuchillo mas cada 2 niveles
	timer.wait_time = maxf(0.35, timer.wait_time * 0.88)
