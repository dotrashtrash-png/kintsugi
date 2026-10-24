extends Node2D

signal elegido(id: String)

# En el Inspector de cada instancia: onsen, torii, biblioteca, puente o santuario
@export var id := "onsen"

const COLOR_RUINA := Color(0.45, 0.45, 0.5)
const DORADO := Color("e8b04a")
const BORDE_NORMAL := Color("4a5a73")
const CREMA := "fff8e7" # texto que alcanza
const FALTA := "e5654a" # texto que falta
const RUTA_DIBUJO := "res://arte/aldea/%s.png"
const RUTA_VETAS := "res://arte/aldea/vetas_oro.png"
const NOMBRES := {"madera": "Madera", "tejas": "Tejas", "oro": "Oro"}
const ANCHO := 232.0 # ancho de la plaquita

var escala_base := Vector2.ONE
var brillo: Tween
var zoom: Tween
var info: Node2D
var panel: PanelContainer
var estilo: StyleBoxFlat
var texto: RichTextLabel

# Si todavia no hay dibujo o vetas, estos quedan en null y no pasa nada.
@onready var dibujo: Sprite2D = get_node_or_null("Dibujo")
@onready var vetas: Sprite2D = get_node_or_null("Vetas")
@onready var cuadro: ColorRect = get_node_or_null("Cuadro")


func _ready() -> void:
	escala_base = scale
	if dibujo and ResourceLoader.exists(RUTA_DIBUJO % id):
		dibujo.texture = load(RUTA_DIBUJO % id)
		if cuadro:
			cuadro.visible = false
	if vetas and ResourceLoader.exists(RUTA_VETAS):
		vetas.texture = load(RUTA_VETAS)
	_crear_info()
	$Boton.pressed.connect(_on_boton_pressed)
	$Boton.mouse_entered.connect(_hover.bind(true))
	$Boton.mouse_exited.connect(_hover.bind(false))
	actualizar()


# Crea por codigo la plaquita. Se agranda sola segun el texto.
func _crear_info() -> void:
	# Alto del dibujo: la plaquita va justo debajo, sin taparlo.
	var alto := 48.0
	if dibujo and dibujo.texture:
		alto = dibujo.texture.get_height() * dibujo.scale.y

	info = Node2D.new()
	info.position = Vector2(0, alto / 2.0 + 6.0)
	# Contra-escala: la letra se ve a su tamano real aunque el edificio tenga Scale.
	info.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)
	add_child(info)

	estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.106, 0.102, 0.18, 0.9) # #1b1a2e
	estilo.set_border_width_all(2)
	estilo.border_color = BORDE_NORMAL
	estilo.content_margin_left = 8
	estilo.content_margin_right = 8
	estilo.content_margin_top = 4
	estilo.content_margin_bottom = 4

	panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", estilo)
	panel.custom_minimum_size = Vector2(ANCHO, 0)
	panel.position = Vector2(-ANCHO / 2.0, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(panel)

	texto = RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.fit_content = true
	texto.scroll_active = false
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("normal_font_size", 16)
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(texto)


func actualizar() -> void:
	var datos: Dictionary = Edificios.LISTA[id]
	var reparado := Estado.esta_reparado(id)
	var puede := Estado.puede_reparar(id)

	if dibujo:
		dibujo.modulate = Color.WHITE if reparado else COLOR_RUINA
	if vetas:
		vetas.visible = reparado
	if cuadro:
		cuadro.color = Color(1.0, 0.8, 0.35) if reparado else Color(0.4, 0.4, 0.45)

	var color_nombre := "e8b04a" if reparado else CREMA
	var t := "[center][color=#%s]%s[/color]" % [color_nombre, datos["nombre"]]
	if not reparado:
		var partes := PackedStringArray()
		for tipo in datos["costo"]:
			partes.append(_pieza(NOMBRES[tipo], Estado.materiales[tipo], datos["costo"][tipo]))
		if datos["aldeanos"] > 0:
			partes.append(_pieza("Aldeanos", Estado.aldeanos, datos["aldeanos"]))
		t += "\n" + " · ".join(partes)
		if not Estado.faltan_requisitos(id).is_empty():
			partes.append("[color=#%s]Antes repara los demás[/color]" % FALTA)
	texto.text = t + "[/center]"

	# Borde dorado solo cuando ya se puede reparar
	estilo.border_color = DORADO if puede else BORDE_NORMAL
	# Que la plaquita se encoja si ahora tiene menos texto
	panel.reset_size.call_deferred()
	_poner_brillo(puede)


# "Madera 12/15": crema si alcanza, rojo si falta
func _pieza(etiqueta: String, tengo: int, necesito: int) -> String:
	var color := CREMA if tengo >= necesito else FALTA
	return "[color=#%s]%s %d/%d[/color]" % [color, etiqueta, tengo, necesito]


# La plaquita late suave cuando ya se puede reparar
func _poner_brillo(activo: bool) -> void:
	if brillo:
		brillo.kill()
		brillo = null
	info.modulate = Color.WHITE
	if activo:
		brillo = create_tween().set_loops()
		brillo.tween_property(info, "modulate", Color(1.3, 1.2, 0.8), 0.6)
		brillo.tween_property(info, "modulate", Color.WHITE, 0.6)


# Al pasar el mouse crece a 1.05 en 0.1 s
func _hover(entra: bool) -> void:
	if zoom:
		zoom.kill()
	zoom = create_tween()
	zoom.tween_property(self, "scale", escala_base * (1.05 if entra else 1.0), 0.1)


# La llama la Aldea al repararlo: el edificio salta y las vetas brillan
func celebrar() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", escala_base * 1.15, 0.12)
	t.tween_property(self, "scale", escala_base, 0.25)
	if vetas:
		vetas.modulate = Color(2.5, 2.2, 1.2)
		create_tween().tween_property(vetas, "modulate", Color.WHITE, 0.8)


func _on_boton_pressed() -> void:
	elegido.emit(id)
