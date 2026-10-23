extends Node2D

const RUTA_SALIR := "res://escenas/run/Run.tscn"
const RUTA_FINAL := "res://escenas/base/Final.tscn"
const RUTA_KOHAKU := "res://arte/yokais/kohaku.png" # si Matta la mueve a arte/aldea/, cambia esta ruta
const COLOR_RUINAS := Color(0.55, 0.55, 0.65) # la aldea al empezar: gris azulado
const TOTAL_EDIFICIOS := 5

const NOMBRES_HEROES := {
	"ronin": "Ronin · katana",
	"miko": "Miko · campana",
	"onmyoji": "Onmyōji · ofuda",
	"kunoichi": "Kunoichi · kunai",
}

var ya_dijo_falta := false

func _ready() -> void:
	for edificio in $Edificios.get_children():
		edificio.elegido.connect(_on_edificio_elegido)
	$UI/BotonSalir.pressed.connect(_on_salir)
	$UI/BotonPrueba.pressed.connect(_on_prueba)
	$UI/BotonPrueba.visible = OS.is_debug_build()
	$UI/BotonBorrar.pressed.connect(_on_borrar)
	$UI/BotonBorrar.visible = OS.is_debug_build()
	Estado.cambio.connect(actualizar)
	preparar_kohaku()
	var saludo := elegir_saludo() # antes de mostrar_ultima_salida(), que la borra
	actualizar()
	mostrar_ultima_salida()
	Audio.musica("aldea")
	if saludo != "":
		$Dialogo.mostrar(saludo)

func _process(_delta: float) -> void:
	# La cola de Kohaku se mueve: cambia de cuadro cada medio segundo
	if $Kohaku.visible and $Kohaku.hframes > 1:
		$Kohaku.frame = int(Time.get_ticks_msec() / 500.0) % $Kohaku.hframes

func preparar_kohaku() -> void:
	if ResourceLoader.exists(RUTA_KOHAKU):
		var tex: Texture2D = load(RUTA_KOHAKU)
		$Kohaku.texture = tex
		# Cuenta los cuadros solos: ancho / alto (2 cuadros de 32x32 = 64x32)
		$Kohaku.hframes = maxi(1, int(tex.get_width() / tex.get_height()))
	else:
		$Kohaku.visible = false

func elegir_saludo() -> String:
	var s: Dictionary = Estado.ultima_salida
	if s.is_empty():
		# Solo la primera vez que llega a la aldea
		return Textos.HARU["inicio"] if Estado.salidas == 0 and Estado.edificios.is_empty() else ""
	return Textos.HARU["volver_bien"] if s["sobrevivio"] else Textos.HARU["volver_mal"]

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

# Solo para probar: borra todo y recarga la aldea.
func _on_borrar() -> void:
	Estado.reiniciar()
	get_tree().reload_current_scene()

func actualizar_heroes() -> void:
	for hijo in $UI/Heroes.get_children():
		hijo.queue_free()
	for id in Estado.heroes_desbloqueados:
		var boton := Button.new()
		var texto: String = NOMBRES_HEROES.get(id, id)
		if id == Estado.heroe_elegido:
			texto = "> " + texto + " <"
		boton.text = texto
		boton.pressed.connect(_on_heroe_elegido.bind(id))
		$UI/Heroes.add_child(boton)

func _on_heroe_elegido(id: String) -> void:
	Estado.heroe_elegido = id
	Estado.guardar()
	actualizar_heroes()
