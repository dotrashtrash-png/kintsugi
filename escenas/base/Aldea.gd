extends Node2D

const RUTA_SALIR := "res://escenas/run/Run.tscn"

func _ready() -> void:
	$UI/BotonSalir.pressed.connect(_on_salir)

func _on_salir() -> void:
	if ResourceLoader.exists(RUTA_SALIR):
		get_tree().change_scene_to_file(RUTA_SALIR)
	else:
		print("Todavia no existe el Run")
