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
	t.offset_top = 16
	t.offset_bottom = 54
	t.add_theme_constant_override("outline_size", 8)
	_decorar_barra_xp()
	_crear_barra_vida()
	$LabelVida.visible = false # la vida ahora es la barra roja con numeros
	_crear_contadores()
	$LabelNivel.offset_top = 18
	$LabelNivel.offset_bottom = 36
	# Casillas de armas y pasivas debajo de la vida
	var columna := VBoxContainer.new()
	columna.position = Vector2(8, 46)
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
	_actualizar_vida(delta) # la vida si cada cuadro: un golpe se tiene que ver al instante
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
	$LabelNivel.text = tr("Nivel %d") % run.nivel
	$BarraXP.max_value = run.experiencia_necesaria
	$BarraXP.value = run.experiencia
	var m: Dictionary = run.recolectado
	contadores["madera"].text = str(m["madera"])
	contadores["tejas"].text = str(m["tejas"])
	contadores["oro"].text = str(m["oro"])
	contadores["aldeanos"].text = str(run.aldeanos_rescatados)
	texto_muertes.text = str(run.muertes)
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


# ---------- Barra de experiencia (arriba, de lado a lado) ----------

func _caja(fondo: Color, borde: Color, ancho_borde: int) -> StyleBoxFlat:
	var c := StyleBoxFlat.new()
	c.bg_color = fondo
	c.border_color = borde
	c.set_border_width_all(ancho_borde)
	return c

func _decorar_barra_xp() -> void:
	var b: ProgressBar = $BarraXP
	b.offset_bottom = 12 # antes 8
	var fondo := _caja(Color("14122a"), NOCHE, 1)
	fondo.border_width_bottom = 2
	fondo.border_color = ORO.darkened(0.45)
	var lleno := _caja(ORO, Color("fff0b8"), 0)
	lleno.border_width_top = 2 # brillo arriba
	lleno.border_width_bottom = 2
	lleno.border_color = Color("fff0b8")
	b.add_theme_stylebox_override("background", fondo)
	b.add_theme_stylebox_override("fill", lleno)
	# Rombitos dorados en las puntas
	for lado in [0, 1]:
		var rombo := ColorRect.new()
		rombo.color = ORO
		rombo.size = Vector2(6, 6)
		rombo.rotation = PI / 4.0
		rombo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rombo.anchor_left = float(lado)
		rombo.anchor_right = float(lado)
		rombo.position = Vector2(-4 if lado == 1 else 4, 2)
		b.add_child(rombo)


# ---------- Barra de vida (roja, minimalista, con los numeros encima) ----------

const ANCHO_VIDA := 190.0
const ALTO_VIDA := 20.0
var barra_vida: ProgressBar
var barra_fantasma: ProgressBar # la parte que se acaba de perder, en claro, baja despacio
var texto_vida: Label
var vida_mostrada := -1

func _crear_barra_vida() -> void:
	var caja := Control.new()
	caja.position = Vector2(8, 18)
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caja)
	# Marco: borde oscuro con una linea dorada adentro
	var marco := Panel.new()
	marco.position = Vector2(14, 0)
	marco.size = Vector2(ANCHO_VIDA + 6, ALTO_VIDA + 6)
	var estilo := _caja(Color("2a0f18"), NOCHE, 2)
	estilo.expand_margin_left = 1
	estilo.expand_margin_right = 1
	estilo.expand_margin_top = 1
	estilo.expand_margin_bottom = 1
	estilo.shadow_color = ORO.darkened(0.2)
	estilo.shadow_size = 1
	marco.add_theme_stylebox_override("panel", estilo)
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(marco)
	barra_fantasma = _barra(Color("f2d0c8"), Color.TRANSPARENT)
	barra_vida = _barra(Color("c42828"), Color("f06e64"))
	for b in [barra_fantasma, barra_vida]:
		b.position = Vector2(17, 3)
		b.size = Vector2(ANCHO_VIDA, ALTO_VIDA)
		caja.add_child(b)
	# Corazon a la izquierda
	var corazon := TextureRect.new()
	corazon.texture = load("res://arte/ui/corazon.png")
	corazon.size = Vector2(27, 24)
	corazon.position = Vector2(0, 1)
	corazon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	corazon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	corazon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(corazon)
	# Numeros grandes encima de la barra
	texto_vida = Label.new()
	texto_vida.position = Vector2(17, 1)
	texto_vida.size = Vector2(ANCHO_VIDA, ALTO_VIDA + 4)
	texto_vida.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_vida.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto_vida.add_theme_font_size_override("font_size", 16)
	texto_vida.add_theme_color_override("font_color", CREMA)
	texto_vida.add_theme_color_override("font_outline_color", Color("1b0a10"))
	texto_vida.add_theme_constant_override("outline_size", 6)
	texto_vida.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(texto_vida)

func _barra(relleno: Color, brillo: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vacio := StyleBoxEmpty.new()
	var lleno := StyleBoxFlat.new()
	lleno.bg_color = relleno
	if brillo.a > 0.0:
		lleno.border_width_top = 3 # brillo arriba: se ve en relieve
		lleno.border_color = brillo
		lleno.border_blend = false
	b.add_theme_stylebox_override("background", vacio)
	b.add_theme_stylebox_override("fill", lleno)
	return b

func _actualizar_vida(delta: float) -> void:
	if run.heroe == null or barra_vida == null:
		return
	var h = run.heroe
	barra_vida.max_value = h.vida_maxima
	barra_fantasma.max_value = h.vida_maxima
	barra_vida.value = h.vida
	# La parte perdida queda en claro un momento y baja suave (estilo Blasphemous)
	if barra_fantasma.value < h.vida:
		barra_fantasma.value = h.vida
	else:
		barra_fantasma.value = move_toward(barra_fantasma.value, h.vida, h.vida_maxima * 0.6 * delta)
	if h.vida != vida_mostrada:
		vida_mostrada = h.vida
		texto_vida.text = "%d / %d" % [h.vida, h.vida_maxima]


# ---------- Contadores con iconos: materiales abajo, calavera de yokais arriba a la derecha ----------

var contadores := {}
var texto_muertes: Label

func _numero(tamano := 16) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tamano)
	l.add_theme_color_override("font_color", CREMA)
	l.add_theme_color_override("font_outline_color", NOCHE)
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _mini_icono(textura: Texture2D) -> TextureRect:
	var t := TextureRect.new()
	t.texture = textura
	t.custom_minimum_size = Vector2(24, 24) # 12 px al doble, nitido
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func _crear_contadores() -> void:
	$LabelMateriales.visible = false
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.anchor_top = 1.0
	fila.anchor_bottom = 1.0
	fila.offset_left = 8
	fila.offset_top = -34
	fila.offset_bottom = -6
	add_child(fila)
	var aldeano := AtlasTexture.new() # primer cuadro de la hoja del aldeano
	aldeano.atlas = load("res://arte/aldea/aldeano.png")
	aldeano.region = Rect2(0, 0, 16, 16)
	var iconos_material := {
		"madera": load("res://arte/ui/madera.png"),
		"tejas": load("res://arte/ui/tejas.png"),
		"oro": load("res://arte/ui/oro.png"),
		"aldeanos": aldeano,
	}
	for clave in ["madera", "tejas", "oro", "aldeanos"]:
		fila.add_child(_mini_icono(iconos_material[clave]))
		var n := _numero()
		n.text = "0"
		n.custom_minimum_size = Vector2(28, 0)
		fila.add_child(n)
		contadores[clave] = n
	# Calavera arriba a la derecha, debajo del nivel
	var muertes := HBoxContainer.new()
	muertes.alignment = BoxContainer.ALIGNMENT_END
	muertes.add_theme_constant_override("separation", 6)
	muertes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	muertes.anchor_left = 1.0
	muertes.anchor_right = 1.0
	muertes.offset_left = -160
	muertes.offset_right = -8
	muertes.offset_top = 38
	muertes.offset_bottom = 62
	add_child(muertes)
	texto_muertes = _numero()
	texto_muertes.text = "0"
	muertes.add_child(texto_muertes)
	var calavera := _mini_icono(load("res://arte/ui/calavera.png"))
	calavera.custom_minimum_size = Vector2(18, 18)
	muertes.add_child(calavera)
