extends Control

# Menú principal: la primera pantalla del juego.
# "Jugar" lleva a la aldea. "Créditos" muestra u oculta el texto de créditos.
# Al rediseñar, NO cambies el nombre ni la ubicación de Botones/BotonJugar,
# Botones/BotonCreditos ni Creditos: este script los busca por nombre.

const RUTA_ALDEA := "res://escenas/base/Aldea.tscn"


func _ready() -> void:
	# Conectar: "cuando presionen este botón, ejecuta esta función".
	$Botones/BotonJugar.pressed.connect(_on_jugar)
	$Botones/BotonCreditos.pressed.connect(_on_creditos)
	$Creditos.visible = false
	# El botón Jugar arranca seleccionado: se puede jugar con Enter, sin mouse.
	$Botones/BotonJugar.grab_focus()


func _on_jugar() -> void:
	# El navegador no deja sonar nada hasta el primer clic: por eso la música arranca en la aldea.
	Audio.sfx("boton")
	get_tree().change_scene_to_file(RUTA_ALDEA)


func _on_creditos() -> void:
	Audio.sfx("boton")
	# "not" invierte: si se veía, se esconde; si estaba escondido, se ve.
	$Creditos.visible = not $Creditos.visible
