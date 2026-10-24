extends Control
# Escena final: Kohaku despierta sobre la aldea reparada.
# 3 paginas de texto encima del dibujo. Clic o Enter pasan; al final vuelve al menu.

const RUTA_MENU := "res://escenas/ui/MenuPrincipal.tscn"
const RUTA_IMAGEN := "res://arte/aldea/final_kohaku.png"
const PAGINAS := [
	"Los faroles del santuario se encienden, uno por uno.",
	"Kohaku abre los ojos. Tsugimura recordó a su guardiana, y las grietas de la aldea brillan con oro.",
	"Lo que se rompe y se repara con cuidado puede ser más bello que antes.\n\nGracias por jugar KINTSUGI.",
]

var pagina := 0

func _ready() -> void:
	if ResourceLoader.exists(RUTA_IMAGEN):
		$Imagen.texture = load(RUTA_IMAGEN)
	$Imagen.modulate.a = 0.0
	create_tween().tween_property($Imagen, "modulate:a", 1.0, 2.0)
	Audio.sfx("reparar")
	mostrar()

func mostrar() -> void:
	$Texto.text = PAGINAS[pagina]
	$Texto.modulate.a = 0.0
	create_tween().tween_property($Texto, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	var avanzar: bool = (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("ui_accept")
	if not avanzar:
		return
	get_viewport().set_input_as_handled()
	Audio.sfx("boton")
	pagina += 1
	if pagina < PAGINAS.size():
		mostrar()
	else:
		set_process_input(false)
		get_tree().change_scene_to_file(RUTA_MENU)
