extends CanvasLayer

# El HUD es lo que se ve encima del juego: barra de experiencia, vida, reloj, nivel y botín.
# No guarda nada: lee los números del Run (su nodo padre) y los muestra.
# Arriba a la izquierda, como en Vampire Survivors: las armas y pasivas que tienes, con su nivel.

const RUTA_ICONO := "res://arte/ui/icono_%s.png"
const NOCHE := Color("1b1a2e")
const ORO := Color("e8b04a")
const CREMA := Color("fff8e7")
const LADO := 34 # tamaño de cada casilla

@onready var run = get_parent()

var reloj := 0.0
var firma := "" # resumen de armas y niveles: si cambia, se redibujan las casillas
var fila_armas: HBoxContainer
var fila_pasivas: HBoxContainer
var iconos := {}


func _ready() -> void:
	# Reloj grande arriba al centro (en la fuente pixel solo se ve nitida en 16 o 32)
	var t: Label = $LabelTiempo
	t.add_theme_font_size_override("font_size", 32)
	t.add_theme_color_override("font_outline_color", NOCHE)
	t.add_theme_constant_override("outline_size", 6)
	t.offset_left = -220
	t.offset_right = 220
	t.offset_top = 10
	t.offset_bottom = 48
	# Casillas de armas y pasivas debajo de la vida
	var columna := VBoxContainer.new()
	columna.position = Vector2(8, 36)
	columna.add_theme_constant_override("separation", 4)
	columna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(columna)
	fila_armas = HBoxContainer.new()
	fila_pasivas = HBoxContainer.new()
	for fila in [fila_armas, fila_pasivas]:
		fila.add_theme_constant_override("separation", 4)
		fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		columna.add_child(fila)
	_actualizar()


func _process(delta: float) -> void:
	# 10 veces por segundo alcanza para el reloj y la vida (cada cuadro era trabajo de mas)
	reloj += delta
	if reloj < 0.1:
		return
	reloj = 0.0
	_actualizar()


func _actualizar() -> void:
	if run.heroe == null:
		return # el HUD arranca antes que el Run: el primer cuadro todavia no hay heroe
	var restante := maxf(0.0, run.duracion - run.tiempo)
	var minutos := int(restante / 60.0)
	var segundos := int(restante) % 60
	if run.jefe_aparecio:
		$LabelTiempo.text = "¡El Gran Tengu!"
	else:
		$LabelTiempo.text = "%d:%02d" % [minutos, segundos]
	$LabelVida.text = tr("Vida %d / %d") % [run.heroe.vida, run.heroe.vida_maxima]
	$LabelNivel.text = tr("Nivel %d") % run.nivel
	$BarraXP.max_value = run.experiencia_necesaria
	$BarraXP.value = run.experiencia
	var m: Dictionary = run.recolectado
	$LabelMateriales.text = tr("Madera %d · Tejas %d · Oro %d · Aldeanos %d") % [m["madera"], m["tejas"], m["oro"], run.aldeanos_rescatados]
	_actualizar_casillas()


# ---------- Casillas de armas y pasivas ----------

func _actualizar_casillas() -> void:
	var h = run.heroe
	var armas := []
	for arma in h.armas.get_children():
		armas.append([String(arma.name), int(arma.nivel)])
	var pasivas := []
	for clave in h.niveles:
		pasivas.append([String(clave), int(h.niveles[clave])])
	var nueva := str(armas) + str(pasivas)
	if nueva == firma:
		return
	firma = nueva
	_llenar(fila_armas, armas)
	_llenar(fila_pasivas, pasivas)


func _llenar(fila: HBoxContainer, lista: Array) -> void:
	for hijo in fila.get_children():
		hijo.queue_free()
	for par in lista:
		fila.add_child(_casilla(par[0], par[1]))


func _casilla(clave: String, nivel: int) -> Control:
	var caja := PanelContainer.new()
	caja.custom_minimum_size = Vector2(LADO, LADO)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(NOCHE, 0.75)
	estilo.border_color = Color(ORO, 0.8)
	estilo.set_border_width_all(1)
	caja.add_theme_stylebox_override("panel", estilo)
	var icono := TextureRect.new()
	icono.texture = _icono(clave)
	icono.custom_minimum_size = Vector2(32, 32)
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(icono)
	var numero := Label.new()
	numero.text = str(nivel)
	numero.add_theme_font_size_override("font_size", 16)
	numero.add_theme_color_override("font_color", CREMA)
	numero.add_theme_color_override("font_outline_color", NOCHE)
	numero.add_theme_constant_override("outline_size", 5)
	numero.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	numero.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	numero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(numero)
	return caja


func _icono(clave: String) -> Texture2D:
	if not iconos.has(clave):
		var ruta := RUTA_ICONO % clave
		iconos[clave] = load(ruta) if ResourceLoader.exists(ruta) else null
	return iconos[clave]
