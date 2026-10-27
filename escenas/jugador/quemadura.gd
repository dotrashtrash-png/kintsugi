extends Node2D
# Quemadura: va pegada a un yokai (es su hijo) mientras arde.
# Le quita "dano_tick" 3 veces, una cada 0.4 s, y se dibuja como un aura de fuego encima.
# La pone la explosion de la Ofuda con Quemadura.aplicar(yokai, dano_tick).
# Si el yokai ya estaba ardiendo, vuelve a empezar la cuenta (no se acumulan dos).

const TICKS := 3
const ENTRE_TICKS := 0.4
const LLAMA := preload("res://arte/ui/kitsunebi_llama.png") # la llama del kitsunebi, en naranja
const COLOR_FUEGO := Color(1.4, 0.75, 0.3) # mas de 1: brilla

var dano_tick := 1
var reloj := 0.0
var ticks_hechos := 0


static func aplicar(yokai: Node, dano: int) -> void:
	if not is_instance_valid(yokai) or yokai.muerto:
		return
	var actual = yokai.get_node_or_null("Quemadura")
	if actual:
		actual.dano_tick = maxi(actual.dano_tick, dano)
		actual.reloj = 0.0
		actual.ticks_hechos = 0
		return
	var q := Node2D.new()
	q.set_script(load("res://escenas/jugador/quemadura.gd"))
	q.name = "Quemadura"
	q.dano_tick = dano
	yokai.add_child(q)


func _physics_process(delta: float) -> void:
	reloj += delta
	if ticks_hechos < TICKS and reloj >= ENTRE_TICKS * (ticks_hechos + 1):
		ticks_hechos += 1
		var yokai = get_parent()
		if is_instance_valid(yokai) and not yokai.muerto:
			yokai.recibir_dano(dano_tick)
	if ticks_hechos >= TICKS:
		queue_free()
		return
	queue_redraw()


# Aura: tres llamitas alrededor del yokai y un brillo naranja
func _draw() -> void:
	var fin := TICKS * ENTRE_TICKS
	var alfa := clampf((fin - reloj) / 0.2, 0.0, 1.0) * clampf(reloj / 0.08, 0.0, 1.0)
	draw_circle(Vector2(0, 2), 9.0, Color(1.0, 0.45, 0.1, 0.22 * alfa))
	var base := int(reloj * 12.0)
	for i in 3:
		var p := Vector2(-7.0 + 7.0 * i, 2.0 - 4.0 * float(i == 1))
		var tam := Vector2(8, 11) * (0.85 + 0.2 * sin(reloj * 14.0 + i * 2.0))
		var cuadro := (base + i) % 4
		draw_texture_rect_region(LLAMA, Rect2(p - Vector2(tam.x / 2.0, tam.y * 0.85), tam), Rect2(cuadro * 12, 0, 12, 14), Color(COLOR_FUEGO, alfa))
