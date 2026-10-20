extends CharacterBody2D

@export var velocidad := 40.0
@export var vida := 10
var heroe: Node2D

func _ready() -> void:
	add_to_group("enemigos")
	heroe = get_tree().get_first_node_in_group("jugador")

func _physics_process(_delta: float) -> void:
	if heroe:
		velocity = global_position.direction_to(heroe.global_position) * velocidad
		move_and_slide()

func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	print("Enemigo recibe ", cantidad, ", vida: ", vida)
	if vida <= 0:
		queue_free()
