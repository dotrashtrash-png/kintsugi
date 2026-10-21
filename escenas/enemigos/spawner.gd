extends Node2D

# Arrastra cada tscn desde Sistema de archivos a estos campos del Inspector.
@export var escena_chochin: PackedScene
@export var escena_kasa: PackedScene
@export var escena_rescate: PackedScene
@export var tope := 150 # máximo de yokais vivos a la vez (la Web se traba con más)
@export var distancia := 260.0 # a qué distancia del héroe aparecen: fuera de la pantalla

var tiempo := 0.0
var heroe

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	$TimerOleada.timeout.connect(generar_oleada)
	$TimerRescate.timeout.connect(generar_rescate)

func _process(delta: float) -> void:
	tiempo += delta
	# Al principio sale una tanda cada 1.2 s; al minuto 6, cada 0.3 s.
	var avance := clampf(tiempo / 360.0, 0.0, 1.0)
	$TimerOleada.wait_time = lerpf(1.2, 0.3, avance)

func generar_oleada() -> void:
	if heroe == null:
		return
	# Minuto 0: 1 yokai por tanda. Minuto 5: 6 por tanda.
	var cantidad := 1 + int(tiempo / 60.0)
	for i in cantidad:
		if get_tree().get_nodes_in_group("enemigos").size() >= tope:
			return
		var yokai: Node2D = elegir_yokai().instantiate()
		add_child(yokai)
		# Punto al azar en un círculo alrededor del héroe.
		var angulo := randf() * TAU
		yokai.global_position = heroe.global_position + Vector2.RIGHT.rotated(angulo) * distancia

func elegir_yokai() -> PackedScene:
	# Desde el minuto 1, 3 de cada 10 son Kasa.
	if tiempo > 60.0 and escena_kasa != null and randf() < 0.3:
		return escena_kasa
	return escena_chochin

func generar_rescate() -> void:
	if escena_rescate == null or heroe == null:
		return
	if get_tree().get_nodes_in_group("rescates").size() > 0:
		return # solo un rescate a la vez
	var rescate: Node2D = escena_rescate.instantiate()
	add_child(rescate)
	# Cerca del héroe, dentro de la pantalla, para que se vea.
	var angulo := randf() * TAU
	rescate.global_position = heroe.global_position + Vector2.RIGHT.rotated(angulo) * randf_range(90.0, 150.0)
