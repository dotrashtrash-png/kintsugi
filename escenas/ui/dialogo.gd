extends CanvasLayer

# Caja de diálogo reutilizable (la usa Juan Cadavid en la aldea desde el jueves).
# Uso:  $Dialogo.mostrar("Las grietas no se esconden, hijo.")
#       $Dialogo.mostrar("¡Gracias!", "Kohaku")   <- otro personaje
# Cuando el jugador la cierra (clic o Enter), emite la señal "cerrado".
# Al rediseñar, NO cambies los nombres Panel, Panel/Nombre ni Panel/Texto.

signal cerrado


func _ready() -> void:
	visible = false


func mostrar(texto: String, nombre := "Abuela Haru") -> void:
	$Panel/Nombre.text = nombre
	$Panel/Texto.text = texto
	visible = true
	Audio.sfx("haru")


# _input recibe el clic ANTES que los botones: así cerrar el diálogo
# no repara por accidente un edificio que esté detrás.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	var es_clic: bool = event is InputEventMouseButton and event.pressed # ": bool" porque Godot no adivina el tipo aquí
	if es_clic or event.is_action_pressed("ui_accept"):
		visible = false
		get_viewport().set_input_as_handled() # "este clic ya lo usé, no se lo pases a nadie más"
		cerrado.emit()
