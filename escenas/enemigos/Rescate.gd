extends Area2D

const TIEMPO_PARA_LIBERAR := 3.0
const ORO_POR_RESCATE := 2

var heroe_dentro := false
var progreso := 0.0
var liberado := false

func _ready() -> void:
	add_to_group("rescates")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = true

func _on_body_exited(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = false

func _process(delta: float) -> void:
	if liberado:
		return
	if heroe_dentro:
		progreso += delta
	else:
		progreso = maxf(0.0, progreso - delta * 0.5) # si sales, la barra baja despacio
	
	$Barra.value = progreso / TIEMPO_PARA_LIBERAR * 100.0
	
	if progreso >= TIEMPO_PARA_LIBERAR:
		liberar()

func liberar() -> void:
	liberado = true
	Audio.sfx("rescate")
	var run = get_tree().get_first_node_in_group("run")
	if run:
		run.agregar_aldeano()
		run.agregar_material("oro", ORO_POR_RESCATE)
	queue_free()
