extends CanvasLayer
# Pausa de la partida: Esc o P.
# Muestra las estadisticas del heroe, lo recolectado, el volumen y deja volver a la aldea.
# La interfaz se arma por codigo: la escena Pausa.tscn es solo este nodo.
# Process Mode = Always: es lo unico que sigue funcionando con el juego congelado.

const NOCHE := Color("1b1a2e")
const PIZARRA := Color("2e3a4f")
const GRIS := Color("4a5a73")
const ORO := Color("e8b04a")
const CREMA := Color("fff8e7")

var abierta := false
var estadisticas: Label
var materiales: Label
var boton_seguir: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	construir()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	var tecla_p: bool = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P
	if not (event.is_action_pressed("ui_cancel") or tecla_p):
		return
	var run = get_parent()
	if run.terminado:
		return
	if not abierta and get_tree().paused:
		return # el menu de mejoras ya tiene el juego en pausa
	get_viewport().set_input_as_handled()
	if abierta:
		cerrar()
	else:
		abrir()


func abrir() -> void:
	abierta = true
	actualizar()
	visible = true
	get_tree().paused = true
	Audio.sfx("boton")
	boton_seguir.grab_focus()


func cerrar() -> void:
	abierta = false
	visible = false
	get_tree().paused = false
	Audio.sfx("boton")


func _on_volver() -> void:
	abierta = false
	visible = false
	get_parent().terminar(false) # vuelve con la mitad de lo recolectado


# ---------- Textos ----------

func actualizar() -> void:
	var run = get_parent()
	var h = run.heroe
	var lineas := PackedStringArray()
	lineas.append("Vida  %d / %d   (regenera %.1f por segundo)" % [h.vida, h.vida_maxima, h.regen])
	lineas.append("Daño  x%.2f   ·   Velocidad  %d   ·   Radio para recoger  %d" % [h.poder, h.velocidad, h.radio_recoger])
	var armas := PackedStringArray()
	for arma in h.armas.get_children():
		armas.append("%s Nv. %d" % [nombre_de(arma.name), arma.nivel])
	lineas.append("Armas:  " + (", ".join(armas) if armas.size() > 0 else "ninguna"))
	var pasivas := PackedStringArray()
	for clave in h.niveles:
		pasivas.append("%s Nv. %d" % [nombre_de(clave), h.niveles[clave]])
	lineas.append("Pasivas:  " + (", ".join(pasivas) if pasivas.size() > 0 else "ninguna"))
	estadisticas.text = "\n".join(lineas)
	var m: Dictionary = run.recolectado
	materiales.text = "Esta salida:  Madera %d · Tejas %d · Oro %d · Aldeanos %d" % [m["madera"], m["tejas"], m["oro"], run.aldeanos_rescatados]


func nombre_de(clave) -> String:
	return Heroes.MEJORAS.get(String(clave), {}).get("nombre", String(clave).capitalize())


# ---------- Construir la interfaz ----------

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


func boton(texto: String) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_stylebox_override("normal", caja(PIZARRA, GRIS))
	b.add_theme_stylebox_override("hover", caja(GRIS, ORO))
	b.add_theme_stylebox_override("focus", caja(GRIS, ORO))
	b.add_theme_stylebox_override("pressed", caja(NOCHE, ORO))
	b.add_theme_color_override("font_color", CREMA)
	b.add_theme_color_override("font_hover_color", ORO)
	b.add_theme_color_override("font_focus_color", ORO)
	return b


func barra_volumen(texto: String, bus: String) -> HBoxContainer:
	var fila := HBoxContainer.new()
	var l := etiqueta(texto, 16)
	l.custom_minimum_size = Vector2(110, 0)
	fila.add_child(l)
	var barra := HSlider.new()
	barra.min_value = 0.0
	barra.max_value = 1.0
	barra.step = 0.05
	barra.value = Audio.volumen(bus)
	barra.custom_minimum_size = Vector2(300, 24)
	barra.value_changed.connect(func(v: float) -> void: Audio.poner_volumen(bus, v))
	fila.add_child(barra)
	return fila


func construir() -> void:
	var sombra := ColorRect.new()
	sombra.color = Color(0, 0, 0, 0.55)
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(sombra)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var panel := PanelContainer.new()
	var estilo := caja(Color(NOCHE, 0.95), ORO)
	estilo.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(panel)
	var columna := VBoxContainer.new()
	columna.add_theme_constant_override("separation", 14)
	panel.add_child(columna)
	var titulo := etiqueta("Pausa", 32, ORO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	columna.add_child(titulo)
	estadisticas = etiqueta("", 16)
	columna.add_child(estadisticas)
	materiales = etiqueta("", 16, ORO)
	columna.add_child(materiales)
	columna.add_child(barra_volumen("Música", "Musica"))
	columna.add_child(barra_volumen("Efectos", "Efectos"))
	boton_seguir = boton("Seguir  (Esc / P)")
	boton_seguir.pressed.connect(cerrar)
	columna.add_child(boton_seguir)
	var volver := boton("Volver a la aldea  (traes la mitad)")
	volver.pressed.connect(_on_volver)
	columna.add_child(volver)
