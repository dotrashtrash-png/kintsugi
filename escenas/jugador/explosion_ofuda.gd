extends Node2D
# Explosion de la Ofuda: cuando un talisman pega, estalla un instante (0.25 s).
# Todo yokai dentro del circulo en ese momento queda ardiendo (ver quemadura.gd).
# La crea talisman.gd y le pone "dano_tick".

const QUEMADURA := preload("res://escenas/jugador/quemadura.gd")
const RADIO := 20.0
const DURACION := 0.25

var dano_tick := 1
var reloj := 0.0


func _ready() -> void:
	# Prende a todos los que alcanza, una sola vez
	var r2 := RADIO * RADIO
	for e in Yokai.todos(get_tree()):
		if is_instance_valid(e) and not e.muerto and global_position.distance_squared_to(e.global_position) < r2:
			QUEMADURA.aplicar(e, dano_tick)


func _physics_process(delta: float) -> void:
	reloj += delta
	if reloj >= DURACION:
		queue_free()
		return
	queue_redraw()


# Destello: un circulo que crece rapido y se apaga, con un anillo y chispas hacia afuera
func _draw() -> void:
	var t := reloj / DURACION # 0 -> 1
	var crece := 1.0 - pow(1.0 - t, 3.0)
	var radio := RADIO * (0.35 + 0.65 * crece)
	var alfa := 1.0 - t
	draw_circle(Vector2.ZERO, radio, Color(1.0, 0.5, 0.15, 0.35 * alfa))
	draw_circle(Vector2.ZERO, radio * 0.55 * (1.0 - t), Color(1.0, 0.9, 0.55, 0.9 * alfa))
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 24, Color(1.0, 0.75, 0.35, alfa), 2.0)
	for i in 8:
		var d := Vector2.RIGHT.rotated(TAU * i / 8.0 + 0.3)
		var p := d * radio * (0.9 + 0.4 * t)
		draw_rect(Rect2(p - Vector2(1, 1), Vector2(2, 2)), Color(1.0, 0.85, 0.4, alfa))
