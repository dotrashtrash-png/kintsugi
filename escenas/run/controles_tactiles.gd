extends CanvasLayer
# Controles para celular: un joystick que aparece donde pongas el dedo y un boton de pausa.
# El Run lo agrega solo si el aparato tiene pantalla tactil; en PC no existe.
# El joystick "aprieta" las mismas acciones del Input Map (izquierda/derecha/arriba/abajo),
# asi el heroe no sabe si lo mueven con teclado o con el dedo.

const RADIO := 56.0 # que tanto hay que arrastrar el dedo para ir a toda velocidad
const ZONA_MUERTA := 0.15
const ACCIONES := ["izquierda", "derecha", "arriba", "abajo"]

var dedo := -1 # indice del dedo que maneja el joystick (-1 = ninguno)
var centro := Vector2.ZERO
var punta := Vector2.ZERO
var dibujo: Control
var boton_pausa: Button


func _ready() -> void:
	layer = 5
	dibujo = Control.new()
	dibujo.set_anchors_preset(Control.PRESET_FULL_RECT)
	dibujo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dibujo.draw.connect(_dibujar)
	add_child(dibujo)

	boton_pausa = Button.new()
	boton_pausa.text = " II "
	boton_pausa.add_theme_font_size_override("font_size", 32)
	boton_pausa.focus_mode = Control.FOCUS_NONE
	boton_pausa.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	boton_pausa.position = Vector2(-96, 40)
	boton_pausa.pressed.connect(_on_pausa)
	add_child(boton_pausa)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and dedo == -1 and not _sobre_boton(event.position):
			dedo = event.index
			centro = event.position
			punta = event.position
		elif not event.pressed and event.index == dedo:
			_soltar()
		dibujo.queue_redraw()
	elif event is InputEventScreenDrag and event.index == dedo:
		punta = event.position
		_aplicar()
		dibujo.queue_redraw()


func _aplicar() -> void:
	var v := (punta - centro) / RADIO
	if v.length() > 1.0:
		v = v.normalized()
	if v.length() < ZONA_MUERTA:
		v = Vector2.ZERO
	_apretar("izquierda", maxf(0.0, -v.x))
	_apretar("derecha", maxf(0.0, v.x))
	_apretar("arriba", maxf(0.0, -v.y))
	_apretar("abajo", maxf(0.0, v.y))


func _apretar(accion: String, fuerza: float) -> void:
	if fuerza > 0.0:
		Input.action_press(accion, fuerza)
	else:
		Input.action_release(accion)


func _soltar() -> void:
	dedo = -1
	for a in ACCIONES:
		Input.action_release(a)
	dibujo.queue_redraw()


# Si el juego se pausa (menu de mejoras o pausa) con el dedo puesto, el heroe no debe seguir caminando
func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_EXIT_TREE:
		_soltar()


func _sobre_boton(pos: Vector2) -> bool:
	return boton_pausa.get_global_rect().grow(12).has_point(pos)


func _on_pausa() -> void:
	var run = get_parent()
	if run.has_node("Pausa") and not get_tree().paused and not run.terminado:
		run.get_node("Pausa").abrir()


func _dibujar() -> void:
	if dedo == -1:
		return
	dibujo.draw_circle(centro, RADIO, Color(1, 0.97, 0.9, 0.18))
	dibujo.draw_arc(centro, RADIO, 0, TAU, 48, Color(0.91, 0.69, 0.29, 0.6), 2.0)
	var p := centro + (punta - centro).limit_length(RADIO)
	dibujo.draw_circle(p, 22.0, Color(0.91, 0.69, 0.29, 0.75))
