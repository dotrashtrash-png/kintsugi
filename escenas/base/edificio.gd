extends Node2D

signal elegido(id: String)

@export var id := "onsen"

const COLOR_RUINA := Color(0.4, 0.4, 0.45)
const COLOR_REPARADO := Color(1.0, 0.8, 0.35) 

func _ready() -> void:
	$Boton.pressed.connect(_on_boton_pressed)
	actualizar()

func actualizar() -> void:
	var datos: Dictionary = Edificios.LISTA[id]
	if Estado.esta_reparado(id):
		$Cuadro.color = COLOR_REPARADO
		$Nombre.text = datos["nombre"]
	else:
		$Cuadro.color = COLOR_RUINA
		$Nombre.text = datos["nombre"] + "\n" + texto_costo()

func texto_costo() -> String:
	var datos: Dictionary = Edificios.LISTA[id]
	var partes := PackedStringArray()
	for tipo in datos["costo"]:
		partes.append("%d %s" % [datos["costo"][tipo], tipo])
	if datos["aldeanos"] > 0:
		partes.append("%d aldeanos" % datos["aldeanos"])
	return ", ".join(partes)

func _on_boton_pressed() -> void:
	elegido.emit(id)
