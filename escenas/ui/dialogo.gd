extends CanvasLayer

# Caja de diálogo reutilizable (la usa Juan Cadavid en la aldea desde el jueves).
# Uso:  $Dialogo.mostrar("Las grietas no se esconden, hijo.")
#       $Dialogo.mostrar("¡Gracias!", "Kohaku")   <- otro personaje
# Cuando el jugador la cierra (clic o Enter), emite la señal "cerrado".
# Al rediseñar, NO cambies los nombres Panel, Panel/Nombre ni Panel/Texto.

signal cerrado

# Retrato de cada personaje. Si el dibujo no existe, queda el cuadro de color.
const RETRATOS := {
	"Abuela Haru": "res://arte/ui/retrato_haru.png",
	"Kohaku": "res://arte/yokais/kohaku.png",
}

var retrato: TextureRect


func _ready() -> void:
	visible = false
	retrato = TextureRect.new()
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	retrato.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Panel/Retrato.add_child(retrato)


func mostrar(texto: String, nombre := "Abuela Haru") -> void:
	$Panel/Nombre.text = nombre
	$Panel/Texto.text = texto
	var ruta: String = RETRATOS.get(nombre, "")
	retrato.texture = load(ruta) if ruta != "" and ResourceLoader.exists(ruta) else null
	$Panel/Retrato.color = Color(0.11, 0.1, 0.18) if retrato.texture else Color(0.75, 0.6, 0.45)
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
