extends Node2D
# Quemadura de la Ofuda: cuando un talisman pega, deja el suelo ardiendo un momento.
# Quema 3 veces a todos los yokais que esten dentro del circulo.
# La crea talisman.gd: Quemadura.new() y le pone "dano_tick".

const RADIO := 18.0
const TICKS := 3
const ENTRE_TICKS := 0.4 # segundos entre quemaduras
const LLAMA := preload("res://arte/ui/kitsunebi_llama.png") # la misma llama, tenida de naranja
const COLOR_FUEGO := Color(1.4, 0.75, 0.3) # mas de 1: brilla

var dano_tick := 1
var reloj := 0.0
var ticks_hechos := 0
var duracion := TICKS * ENTRE_TICKS + 0.25


func _ready() -> void:
	pass # se dibuja encima de los yokais: se ve que les esta quemando


func _physics_process(delta: float) -> void:
	reloj += delta
	# Tick 1 a los 0.4 s, 2 a los 0.8 s, 3 a los 1.2 s
	if ticks_hechos < TICKS and reloj >= ENTRE_TICKS * (ticks_hechos + 1):
		ticks_hechos += 1
		_quemar()
	if reloj >= duracion:
		queue_free()
		return
	queue_redraw()


func _quemar() -> void:
	var r2 := RADIO * RADIO
	for e in Yokai.todos(get_tree()):
		if is_instance_valid(e) and not e.muerto and global_position.distance_squared_to(e.global_position) < r2:
			e.recibir_dano(dano_tick)


func _draw() -> void:
	var vida := 1.0 - reloj / duracion
	var alfa := minf(1.0, vida * 3.0) # se apaga al final
	# Brasa en el suelo
	draw_circle(Vector2.ZERO, RADIO, Color(1.0, 0.45, 0.15, 0.22 * alfa))
	draw_circle(Vector2.ZERO, RADIO * 0.55, Color(1.0, 0.75, 0.3, 0.25 * alfa))
	# Llamitas que bailan alrededor
	var cuadro_base := int(reloj * 12.0)
	for i in 5:
		var ang := TAU * i / 5.0 + reloj * 1.5
		var p := Vector2.RIGHT.rotated(ang) * RADIO * 0.6
		var cuadro := (cuadro_base + i) % 4
		var tam := Vector2(10, 13) * (0.85 + 0.2 * sin(reloj * 10.0 + i))
		draw_texture_rect_region(LLAMA, Rect2(p - Vector2(tam.x / 2.0, tam.y * 0.8), tam), Rect2(cuadro * 12, 0, 12, 14), Color(COLOR_FUEGO, alfa))
