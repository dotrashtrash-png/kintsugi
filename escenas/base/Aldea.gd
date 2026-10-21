extends Node2D

const RUTA_SALIR := "res://escenas/run/Run.tscn"

func _ready() -> void:
	for edificio in $Edificios.get_children():
		edificio.elegido.connect(_on_edificio_elegido)
	$UI/BotonSalir.pressed.connect(_on_salir)
	$UI/BotonPrueba.pressed.connect(_on_prueba)
	$UI/BotonPrueba.visible = OS.is_debug_build() 
	Estado.cambio.connect(actualizar)
	actualizar()
	mostrar_ultima_salida()
	Audio.musica("aldea")
	Audio.subir_capa(1 + Estado.edificios.size())

func actualizar() -> void:
	var m: Dictionary = Estado.materiales
	$UI/LabelMateriales.text = "Madera %d · Tejas %d · Oro %d · Aldeanos %d" % [m["madera"], m["tejas"], m["oro"], Estado.aldeanos]
	for edificio in $Edificios.get_children():
		edificio.actualizar()
	actualizar_heroes()

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
	var nombre: String = Edificios.LISTA[id]["nombre"]
	if Estado.esta_reparado(id):
		$UI/LabelMensaje.text = nombre + " ya está reparado."
		return
	if not Estado.reparar(id):
		$UI/LabelMensaje.text = "Te falta material o aldeanos para " + nombre + "."
		return
	Audio.sfx("reparar")
	Audio.subir_capa(1 + Estado.edificios.size())
	$UI/LabelMensaje.text = "¡Reparaste " + nombre + " con oro!"
	if id == "torii":
		$UI/LabelMensaje.text += " La Miko se une."
	elif id == "biblioteca":
		$UI/LabelMensaje.text += " El Onmyōji se une."
	elif id == "santuario":
		$UI/LabelMensaje.text = "¡Kohaku despierta! (aquí irá el final)"

func _on_salir() -> void:
	get_tree().change_scene_to_file(RUTA_SALIR)

func _on_prueba() -> void:
	Estado.agregar("madera", 20)
	Estado.agregar("tejas", 20)
	Estado.agregar("oro", 10)
	Estado.aldeanos += 5
	Estado.cambio.emit()
	
const NOMBRES_HEROES := {
	"ronin": "Ronin · katana",
	"miko": "Miko · campana",
	"onmyoji": "Onmyōji · ofuda",
	"kunoichi": "Kunoichi · kunai",
}

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
	actualizar_heroes()
