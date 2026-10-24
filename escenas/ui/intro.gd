extends Control
# Intro: 4 paginas con dibujo y texto que cuentan por que la aldea esta en ruinas.
# Clic, Enter o Espacio pasan de pagina. Esc la salta completa.

const RUTA_ALDEA := "res://escenas/base/Aldea.tscn"
const RUTA_IMAGEN := "res://arte/intro/intro_%d.png"
const PAGINAS := [
	"Al pie de la montaña está Tsugimura. En la cima, el santuario de Kohaku, la zorra blanca de nueve colas que cuidaba la aldea.",
	"Con los años, la gente se fue ocupando en otras cosas. Nadie volvió a subir al santuario. Los faroles se apagaron, uno por uno.",
	"La noche del Desfile de los Cien Demonios, nada detuvo a los yokais. Las casas quedaron en ruinas y los aldeanos se escondieron.",
	"La abuela Haru se quedó en su taller. Ella sabe reparar con oro. Pero alguien tiene que salir a buscar lo que se perdió.",
]

var pagina := 0

func _ready() -> void:
	mostrar()

func mostrar() -> void:
	var ruta := RUTA_IMAGEN % (pagina + 1)
	if ResourceLoader.exists(ruta):
		$Imagen.texture = load(ruta)
	$Texto.text = PAGINAS[pagina]
	$Texto.modulate.a = 0.0
	create_tween().tween_property($Texto, "modulate:a", 1.0, 0.6)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		terminar()
		return
	var avanzar: bool = (event is InputEventMouseButton and event.pressed) or event.is_action_pressed("ui_accept")
	if not avanzar:
		return
	get_viewport().set_input_as_handled()
	Audio.sfx("boton")
	pagina += 1
	if pagina < PAGINAS.size():
		mostrar()
	else:
		terminar()

func terminar() -> void:
	set_process_input(false)
	Estado.vio_intro = true
	if Estado.has_method("guardar"):
		Estado.guardar()
	get_tree().change_scene_to_file(RUTA_ALDEA)
