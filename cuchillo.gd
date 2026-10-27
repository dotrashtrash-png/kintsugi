extends Node2D
# Un cuchillo del Kunai: vuela recto y atraviesa a todos los yokais que toca.

var direccion := Vector2.RIGHT
var dano := 7
var velocidad := 320.0
var vida_util := 0.9 # segundos antes de desaparecer
var golpeados: Array = [] # cada yokai recibe un solo golpe de este cuchillo
const DIBUJO := preload("res://arte/ui/kunai_proyectil.png") # kunai chiquito, punta a la derecha

func _ready() -> void:
	rotation = direccion.angle()
	var s := Sprite2D.new()
	s.texture = DIBUJO
	add_child(s)
	if has_node("ColorRect"):
		$ColorRect.visible = false

func _physics_process(delta: float) -> void:
	vida_util -= delta
	if vida_util <= 0.0:
		queue_free()
		return
	global_position += direccion * velocidad * delta
	for e in Yokai.todos(get_tree()):
		if not is_instance_valid(e) or e in golpeados:
			continue
		if global_position.distance_to(e.global_position) < 9.0:
			golpeados.append(e)
			e.recibir_dano(dano)
