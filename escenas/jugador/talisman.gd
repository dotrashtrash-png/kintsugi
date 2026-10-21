extends Node2D
# Un talisman de la Ofuda: persigue a su objetivo y le pega una vez.

var objetivo: Node2D
var dano := 6
var velocidad := 260.0
var vida_util := 1.5 # segundos antes de desaparecer si no pega
var direccion := Vector2.RIGHT

func _physics_process(delta: float) -> void:
	vida_util -= delta
	if vida_util <= 0.0:
		queue_free()
		return
	if is_instance_valid(objetivo):
		direccion = global_position.direction_to(objetivo.global_position)
	global_position += direccion * velocidad * delta
	rotation = direccion.angle()
	for e in get_tree().get_nodes_in_group("enemigos"):
		if is_instance_valid(e) and global_position.distance_to(e.global_position) < 8.0:
			e.recibir_dano(dano)
			queue_free()
			return
