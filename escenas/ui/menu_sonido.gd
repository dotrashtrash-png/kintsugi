extends CanvasLayer
# Ventanita de sonido: barras de Musica y Efectos. Se abre desde el menu principal y la aldea.
# Uso: MenuSonido.abrir(self)   (se arma sola por codigo y se borra al cerrarla)
class_name MenuSonido

const NOCHE := Color("1b1a2e")
const PIZARRA := Color("2e3a4f")
const GRIS := Color("4a5a73")
const ORO := Color("e8b04a")
const CREMA := Color("fff8e7")

var boton_listo: Button
var foco_anterior: Control


static func abrir(desde: Node) -> void:
	var m := MenuSonido.new()
	desde.add_child(m)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	foco_anterior = get_viewport().gui_get_focus_owner()
	construir()
	Audio.sfx("boton")
	boton_listo.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		cerrar()


func cerrar() -> void:
	Audio.sfx("boton")
	if is_instance_valid(foco_anterior) and foco_anterior.is_visible_in_tree():
		foco_anterior.grab_focus()
	queue_free()


func caja(fondo: Color, borde: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fondo
	s.border_color = borde
	s.set_border_width_all(2)
	s.set_content_margin_all(12)
	return s


func etiqueta(texto: String, tamano: int, color := CREMA) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", color)
	return l


func barra(texto: String, bus: String) -> HBoxContainer:
	var fila := HBoxContainer.new()
	var l := etiqueta(texto, 16)
	l.custom_minimum_size = Vector2(110, 0)
	fila.add_child(l)
	var b := HSlider.new()
	b.min_value = 0.0
	b.max_value = 1.0
	b.step = 0.05
	b.value = Audio.volumen(bus)
	b.custom_minimum_size = Vector2(300, 32)
	b.value_changed.connect(func(v: float) -> void: Audio.poner_volumen(bus, v))
	fila.add_child(b)
	return fila


func construir() -> void:
	var sombra := ColorRect.new()
	sombra.color = Color(0, 0, 0, 0.55)
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	sombra.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed: cerrar())
	add_child(sombra)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	var panel := PanelContainer.new()
	var estilo := caja(Color(NOCHE, 0.95), ORO)
	estilo.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(panel)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	panel.add_child(columna)
	var titulo := etiqueta("Sonido", 32, ORO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	columna.add_child(barra("Música", "Musica"))
	columna.add_child(barra("Efectos", "Efectos"))
	boton_listo = Button.new()
	boton_listo.text = "Listo"
	boton_listo.add_theme_font_size_override("font_size", 16)
	boton_listo.add_theme_stylebox_override("normal", caja(PIZARRA, GRIS))
	boton_listo.add_theme_stylebox_override("hover", caja(GRIS, ORO))
	boton_listo.add_theme_stylebox_override("focus", caja(GRIS, ORO))
	boton_listo.add_theme_stylebox_override("pressed", caja(NOCHE, ORO))
	boton_listo.add_theme_color_override("font_color", CREMA)
	boton_listo.add_theme_color_override("font_hover_color", ORO)
	boton_listo.add_theme_color_override("font_focus_color", ORO)
	boton_listo.pressed.connect(cerrar)
	columna.add_child(boton_listo)
