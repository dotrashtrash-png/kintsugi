extends Node2D

const RUTA_SALIR := "res://escenas/run/Run.tscn"
const RUTA_FINAL := "res://escenas/base/Final.tscn"
# Busca a Kohaku en estas rutas, en orden. Usa la primera que exista.
const RUTAS_KOHAKU := [
	"res://arte/aldea/kohaku.png",
	"res://arte/yokais/kohaku.png",
]
const RUTA_PISO := "res://arte/aldea/piso_aldea.png" # 384x216: a x3 llena la ventana
const COLOR_RUINAS := Color(0.55, 0.55, 0.65) # la aldea al empezar: gris azulado
const TOTAL_EDIFICIOS := 5

# Selector de heroe en tarjetas
const ORDEN_HEROES := ["ronin", "miko", "onmyoji", "kunoichi"]
const TITULO_HEROE := {"ronin": "Ronin", "miko": "Miko", "onmyoji": "Onmyōji", "kunoichi": "Kunoichi"}
const REQUISITO_HEROE := {
	"miko": "Repara el torii",
	"onmyoji": "Repara la biblioteca",
	"kunoichi": "Repara el puente",
}
const DORADO_TARJETA := Color("e8b04a")

# Panel de botin
const ICONOS_BOTIN := {
	"madera": "res://arte/ui/madera.png",
	"tejas": "res://arte/ui/tejas.png",
	"oro": "res://arte/ui/oro.png",
}
const NOMBRE_BOTIN := {"madera": "Madera", "tejas": "Tejas", "oro": "Oro"}

var ya_dijo_falta := false
var capa_botin: CanvasLayer


func _ready() -> void:
	for edificio in $Edificios.get_children():
		edificio.elegido.connect(_on_edificio_elegido)
	$UI/BotonSalir.pressed.connect(_on_salir)
	$UI/BotonPrueba.pressed.connect(_on_prueba)
	$UI/BotonPrueba.visible = OS.is_debug_build()
	$UI/BotonBorrar.pressed.connect(_on_borrar)
	$UI/BotonBorrar.visible = true # los jurados lo usan para empezar de cero
	# Boton de Sonido debajo de Borrar partida (misma forma)
	var boton_sonido: Button = $UI/BotonBorrar.duplicate(Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS)
	boton_sonido.name = "BotonSonido"
	boton_sonido.text = "Sonido"
	boton_sonido.position.y += 38
	boton_sonido.pressed.connect(func() -> void: MenuSonido.abrir(self))
	$UI.add_child(boton_sonido)
	Estado.cambio.connect(actualizar)
	poner_piso()
	preparar_kohaku()
	var saludo := elegir_saludo() # antes de mostrar_ultima_salida(), que la borra
	var salida: Dictionary = Estado.ultima_salida.duplicate(true) # copia para el panel
	actualizar()
	mostrar_ultima_salida()
	Audio.musica("aldea")
	if not salida.is_empty():
		await _mostrar_botin(salida) # el panel va ANTES que Haru
	if saludo != "":
		$Dialogo.mostrar(saludo)


func _process(_delta: float) -> void:
	# La cola de Kohaku se mueve: cambia de cuadro cada medio segundo
	if $Kohaku.visible and $Kohaku.hframes > 1:
		$Kohaku.frame = int(Time.get_ticks_msec() / 500.0) % $Kohaku.hframes


# Pone el piso de la aldea encima del fondo gris. El Tinte (CanvasModulate) lo
# pinta gris en ruinas y le devuelve el color al reparar, igual que a los edificios.
func poner_piso() -> void:
	if not ResourceLoader.exists(RUTA_PISO):
		return
	var piso := Sprite2D.new()
	piso.name = "Piso"
	piso.texture = load(RUTA_PISO)
	piso.centered = false
	piso.scale = Vector2(3, 3)
	add_child(piso)
	move_child(piso, $Fondo.get_index() + 1)


func preparar_kohaku() -> void:
	for ruta in RUTAS_KOHAKU:
		if ResourceLoader.exists(ruta):
			var tex: Texture2D = load(ruta)
			$Kohaku.texture = tex
			# Cuenta los cuadros solos: ancho / alto (2 cuadros de 32x32 = 64x32)
			$Kohaku.hframes = maxi(1, int(tex.get_width() / tex.get_height()))
			return
	$Kohaku.visible = false


func elegir_saludo() -> String:
	var s: Dictionary = Estado.ultima_salida
	if s.is_empty():
		# Solo la primera vez que llega a la aldea
		return Textos.HARU["inicio"] if Estado.salidas == 0 and Estado.edificios.is_empty() else ""
	# 1. Primer aldeano rescatado (antes no tenia ninguno)
	if s["aldeanos"] > 0 and Estado.aldeanos == s["aldeanos"]:
		return Textos.HARU["primer_aldeano"]
	# 2. Pista: 5 salidas y nada reparado
	if Estado.salidas == 5 and Estado.edificios.is_empty():
		return Textos.HARU["pista"]
	# 3. Frase al azar
	var lista: Array = Textos.HARU["volver_bien"] if s["sobrevivio"] else Textos.HARU["volver_mal"]
	return lista.pick_random()


func actualizar() -> void:
	var m: Dictionary = Estado.materiales
	$UI/LabelMateriales.text = "Madera %d · Tejas %d · Oro %d · Aldeanos %d" % [m["madera"], m["tejas"], m["oro"], Estado.aldeanos]
	for edificio in $Edificios.get_children():
		edificio.actualizar()
	actualizar_heroes()
	actualizar_color()


# Mas edificios reparados = mas color en la aldea y Kohaku mas visible
func actualizar_color() -> void:
	var avance := float(Estado.edificios.size()) / TOTAL_EDIFICIOS
	create_tween().tween_property($Tinte, "color", COLOR_RUINAS.lerp(Color.WHITE, avance), 1.0)
	var opacidad := 0.2 + 0.16 * Estado.edificios.size()
	create_tween().tween_property($Kohaku, "modulate:a", opacidad, 1.0)


func mostrar_ultima_salida() -> void:
	var s: Dictionary = Estado.ultima_salida
	if s.is_empty():
		$UI/LabelMensaje.text = "Toca un edificio en ruinas para repararlo."
		return
	var b: Dictionary = s["botin"]
	var inicio := "Volviste sano y salvo." if s["sobrevivio"] else "Caíste, pero trajiste la mitad."
	$UI/LabelMensaje.text = "%s Trajiste %d madera, %d tejas, %d oro y %d aldeanos." % [inicio, b["madera"], b["tejas"], b["oro"], s["aldeanos"]]
	Estado.ultima_salida = {}


func _on_edificio_elegido(id: String) -> void:
	if $Dialogo.visible:
		return
	var nombre: String = Edificios.LISTA[id]["nombre"]
	if Estado.esta_reparado(id):
		$UI/LabelMensaje.text = nombre + " ya está reparado."
		return
	if not Estado.faltan_requisitos(id).is_empty():
		$UI/LabelMensaje.text = nombre + " se repara al final: primero los otros edificios."
		return
	if not Estado.reparar(id):
		$UI/LabelMensaje.text = "Te falta material o aldeanos para " + nombre + "."
		if not ya_dijo_falta:
			ya_dijo_falta = true
			$Dialogo.mostrar(Textos.HARU["falta"])
		return
	Audio.sfx("reparar")
	for edificio in $Edificios.get_children():
		if edificio.id == id:
			edificio.celebrar()
	$UI/LabelMensaje.text = "¡Reparaste " + nombre + " con oro!"
	$Dialogo.mostrar(Textos.HARU[id])
	if id == "santuario":
		await $Dialogo.cerrado
		get_tree().change_scene_to_file(RUTA_FINAL)


func _on_salir() -> void:
	get_tree().change_scene_to_file(RUTA_SALIR)


# Solo para probar: da materiales sin jugar.
func _on_prueba() -> void:
	Estado.agregar("madera", 20)
	Estado.agregar("tejas", 20)
	Estado.agregar("oro", 10)
	Estado.aldeanos += 5
	Estado.cambio.emit()


# Solo para probar: borra la partida guardada y recarga la aldea.
func _on_borrar() -> void:
	Estado.reiniciar()
	get_tree().reload_current_scene()


func _on_heroe_elegido(id: String) -> void:
	Estado.heroe_elegido = id
	Estado.guardar()
	actualizar_heroes()


# ---------- Selector de heroe en tarjetas ----------

func actualizar_heroes() -> void:
	for hijo in $UI/Heroes.get_children():
		hijo.queue_free()
	$UI/Heroes.add_theme_constant_override("separation", 6)
	for id in ORDEN_HEROES:
		if Heroes.LISTA.has(id):
			$UI/Heroes.add_child(_crear_tarjeta(id))


func _estilo_tarjeta(borde: Color, fondo: Color) -> StyleBoxFlat:
	var e := StyleBoxFlat.new()
	e.bg_color = fondo
	e.border_color = borde
	e.set_border_width_all(2)
	return e


func _crear_tarjeta(id: String) -> Button:
	var datos: Dictionary = Heroes.LISTA[id]
	var libre: bool = Estado.heroes_desbloqueados.has(id)
	var elegido: bool = libre and id == Estado.heroe_elegido

	var boton := Button.new()
	boton.custom_minimum_size = Vector2(104, 130)
	boton.disabled = not libre
	var fondo := Color(0.106, 0.102, 0.18, 0.92)
	var borde_normal := DORADO_TARJETA if elegido else Color("4a5a73")
	boton.add_theme_stylebox_override("normal", _estilo_tarjeta(borde_normal, fondo))
	boton.add_theme_stylebox_override("hover", _estilo_tarjeta(DORADO_TARJETA, Color(0.18, 0.2, 0.3, 0.95)))
	boton.add_theme_stylebox_override("pressed", _estilo_tarjeta(DORADO_TARJETA, fondo))
	boton.add_theme_stylebox_override("disabled", _estilo_tarjeta(Color("2e3a4f"), Color(0.06, 0.06, 0.1, 0.92)))
	boton.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	boton.pressed.connect(_on_heroe_elegido.bind(id))

	var caja := VBoxContainer.new()
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	caja.add_theme_constant_override("separation", 2)
	boton.add_child(caja)
	caja.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dibujo grande: cuadro 0 (de frente) de la hoja, a escala 4
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(64, 64)
	holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_child(holder)

	var figura: Control
	var ruta: String = datos.get("sprite", "")
	if ruta != "" and ResourceLoader.exists(ruta):
		var atlas := AtlasTexture.new()
		atlas.atlas = load(ruta)
		atlas.region = Rect2(0, 0, 16, 16)
		var imagen := TextureRect.new()
		imagen.texture = atlas
		figura = imagen
	else:
		# Todavia no hay dibujo: cuadro azul, como en la partida
		var c := ColorRect.new()
		c.color = Color(0, 0.5, 1)
		figura = c
	figura.size = Vector2(16, 16)
	figura.scale = Vector2(4, 4)
	figura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(figura)

	if not libre:
		figura.modulate = Color.BLACK # silueta
	if elegido:
		var salto := figura.create_tween().set_loops()
		salto.tween_property(figura, "position:y", -4.0, 0.25)
		salto.tween_property(figura, "position:y", 0.0, 0.25)

	if libre:
		caja.add_child(_etiqueta(TITULO_HEROE.get(id, id), Color("fff8e7")))
		# Arma con su icono
		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ruta_icono := "res://arte/ui/icono_%s.png" % datos["arma"]
		if ResourceLoader.exists(ruta_icono):
			var icono := TextureRect.new()
			icono.texture = load(ruta_icono)
			icono.custom_minimum_size = Vector2(16, 16)
			icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fila.add_child(icono)
		fila.add_child(_etiqueta(String(datos["arma"]).capitalize(), DORADO_TARJETA))
		caja.add_child(fila)
	else:
		var aviso := _etiqueta(REQUISITO_HEROE.get(id, "Bloqueado"), Color("e5654a"))
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		aviso.custom_minimum_size = Vector2(92, 0)
		caja.add_child(aviso)
	return boton


func _etiqueta(texto: String, color: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


# ---------- Panel de botin al volver ----------

func _mostrar_botin(salida: Dictionary) -> void:
	var botin: Dictionary = salida["botin"]
	var gano: bool = salida["sobrevivio"]

	capa_botin = CanvasLayer.new()
	capa_botin.layer = 8 # sobre la aldea, bajo el dialogo (layer 10)
	add_child(capa_botin)

	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_botin.add_child(centro)

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.106, 0.102, 0.18, 0.95)
	estilo.border_color = Color("e8b04a")
	estilo.set_border_width_all(2)
	estilo.set_content_margin_all(16)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", estilo)
	panel.custom_minimum_size = Vector2(320, 0)
	centro.add_child(panel)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 8)
	panel.add_child(caja)

	# Titulo: dorado si sobrevivio, bermellon si cayo
	var titulo := Label.new()
	titulo.text = "¡Sobreviviste!" if gano else "Caíste…"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 32)
	titulo.add_theme_color_override("font_color", Color("e8b04a") if gano else Color("c8402e"))
	caja.add_child(titulo)

	if not gano:
		caja.add_child(_linea_botin("Trajiste la mitad", Color("fff8e7")))

	# Una fila por cada cosa: icono + "+12 Madera" que sube de 0 al valor
	var filas: Array = []
	for tipo in ["madera", "tejas", "oro"]:
		filas.append(_fila_botin(tipo, int(botin.get(tipo, 0))))
	filas.append(_fila_botin("aldeanos", int(salida["aldeanos"])))
	for f in filas:
		caja.add_child(f["nodo"])

	var pista := _linea_botin("Clic o Enter para seguir", Color(1, 0.97, 0.9, 0.6))
	pista.add_theme_font_size_override("font_size", 16)
	caja.add_child(pista)

	# Entrada: escala de 0.85 a 1 en 0.15 s
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	var entra := capa_botin.create_tween().set_parallel(true)
	entra.tween_property(panel, "scale", Vector2.ONE, 0.15)
	entra.tween_property(panel, "modulate:a", 1.0, 0.15)

	# Los numeros suben de 0 al valor en 0.6 s
	var sube := capa_botin.create_tween().set_parallel(true)
	for f in filas:
		sube.tween_method(f["poner"], 0, f["valor"], 0.6)

	# Espera un clic o Enter
	await _esperar_cierre()
	capa_botin.queue_free()


func _fila_botin(tipo: String, valor: int) -> Dictionary:
	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 8)
	var ruta: String = ICONOS_BOTIN.get(tipo, "")
	if ruta != "" and ResourceLoader.exists(ruta):
		var icono := TextureRect.new()
		icono.texture = load(ruta)
		icono.custom_minimum_size = Vector2(24, 24)
		icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		fila.add_child(icono)
	var nombre: String = NOMBRE_BOTIN.get(tipo, "Aldeanos")
	var etiqueta := _linea_botin("+0 " + nombre, Color("fff8e7") if valor > 0 else Color(1, 0.97, 0.9, 0.5))
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	etiqueta.custom_minimum_size = Vector2(150, 0)
	fila.add_child(etiqueta)
	var poner := func(n: int) -> void:
		etiqueta.text = "+%d %s" % [n, nombre]
	return {"nodo": fila, "valor": valor, "poner": poner}


func _linea_botin(texto: String, color: Color) -> Label:
	var l := Label.new()
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", color)
	return l


# Detiene la funcion hasta que haya clic o Enter (espera 0.4 s para no cerrarse solo)
func _esperar_cierre() -> void:
	await get_tree().create_timer(0.4).timeout
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Audio.sfx("boton")
			await get_tree().create_timer(0.1).timeout # que el clic no llegue al dialogo
			return
