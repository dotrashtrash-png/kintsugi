extends Node2D
# Un talisman de la Ofuda: persigue a su objetivo ardiendo, le pega una vez y estalla.
# La explosion deja ardiendo a los yokais que alcanza: 3 quemaduras de 15% del golpe.

const EXPLOSION := preload("res://escenas/jugador/explosion_ofuda.gd")
const PORCENTAJE_QUEMADURA := 0.15 # cada una de las 3 quemaduras

var objetivo: Node2D
var dano := 6
var velocidad := 260.0
var vida_util := 1.5 # segundos antes de desaparecer si no pega
var direccion := Vector2.RIGHT
var reloj := 0.0
var brasas: Array[Vector2] = [] # chispitas que va dejando atras


func _physics_process(delta: float) -> void:
	vida_util -= delta
	reloj += delta
	if vida_util <= 0.0:
		queue_free()
		return
	if is_instance_valid(objetivo):
		direccion = global_position.direction_to(objetivo.global_position)
	global_position += direccion * velocidad * delta
	rotation = direccion.angle()
	# Estela de brasas (en coordenadas del mundo, se dibujan relativas)
	brasas.push_front(global_position)
	if brasas.size() > 6:
		brasas.pop_back()
	queue_redraw()
	for e in Yokai.todos(get_tree()):
		if is_instance_valid(e) and global_position.distance_squared_to(e.global_position) < 64.0:
			e.recibir_dano(dano)
			_estallar()
			queue_free()
			return


func _estallar() -> void:
	var x := EXPLOSION.new()
	x.dano_tick = maxi(1, int(round(dano * PORCENTAJE_QUEMADURA)))
	x.position = global_position # antes de entrar al arbol: en _ready ya sabe donde esta
	get_tree().current_scene.add_child(x)


# El papel arde: el sprite parpadea a naranja y deja chispas detras
func _draw() -> void:
	var parpadeo := 0.5 + 0.5 * sin(reloj * 30.0)
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1.0, 0.8 + 0.2 * parpadeo, 0.6 + 0.3 * parpadeo)
	# Llamita en la cola del talisman
	draw_circle(Vector2(-5, 0), 3.0 + parpadeo, Color(1.0, 0.55, 0.15, 0.85))
	draw_circle(Vector2(-5, 0), 1.5, Color(1.0, 0.9, 0.5))
	# Brasas que se quedan atras y se achican
	for i in range(1, brasas.size()):
		var p := (brasas[i] - global_position).rotated(-rotation)
		var t := 1.0 - float(i) / brasas.size()
		var lado := 2.0 * t + 0.5
		draw_rect(Rect2(p + Vector2(-3, (i % 3) - 1.0) - Vector2(lado, lado) / 2.0, Vector2(lado, lado)), Color(1.0, 0.5 + 0.3 * t, 0.15, 0.9 * t))
