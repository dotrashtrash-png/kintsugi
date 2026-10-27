class_name NumeroDano
extends Label
# Numero de dano que sube y se desvanece encima del yokai (como en Vampire Survivors).
# Uso: NumeroDano.crear(self, cantidad)  desde recibir_dano() de cualquier enemigo.

const MAXIMO_EN_PANTALLA := 20 # en la Web, mas numeros que esto bajan los FPS (al final del run se notaba)

static var vivos := 0 # contador barato (antes se pedia el grupo en cada golpe)

static func crear(donde: Node2D, cantidad: int) -> void:
	var arbol := donde.get_tree()
	if vivos >= MAXIMO_EN_PANTALLA:
		return
	var n := NumeroDano.new()
	vivos += 1
	n.tree_exited.connect(func() -> void: NumeroDano.vivos -= 1)
	n.text = str(cantidad)
	# La fuente pixel se rompe en 8 px ("10" se leia "ID"): se dibuja en 16 y se achica a la mitad
	n.add_theme_font_size_override("font_size", 16)
	n.scale = Vector2(0.5, 0.5)
	n.add_theme_color_override("font_color", Color("fff8e7"))
	n.add_theme_color_override("font_outline_color", Color("1b1a2e"))
	n.add_theme_constant_override("outline_size", 5)
	n.z_index = 50
	arbol.current_scene.add_child(n)
	n.global_position = donde.global_position + Vector2(randf_range(-8, 2), -20)
	var t := n.create_tween()
	t.tween_property(n, "position:y", n.position.y - 10, 0.45)
	t.parallel().tween_property(n, "modulate:a", 0.0, 0.25).set_delay(0.25)
	t.tween_callback(n.queue_free)
