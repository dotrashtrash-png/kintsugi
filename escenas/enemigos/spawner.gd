extends Node2D

@export var escena_chochin: PackedScene = preload("res://escenas/enemigos/Chochin.tscn")
@export var escena_kasa: PackedScene = preload("res://escenas/enemigos/KasaObake.tscn")
@export var escena_nurikabe: PackedScene = preload("res://escenas/enemigos/Nurikabe.tscn")
@export var escena_rescate: PackedScene = preload("res://escenas/enemigos/Rescate.tscn")
@export var tope: int = 150 # maximo de yokais vivos a la vez (la Web se traba con mas)
@export var distancia: float = 260.0 # a que distancia del heroe aparecen: fuera de la pantalla
@export var vida_extra_por_minuto: float = 0.5 # +35% de vida por cada minuto que pasa

# Minutos en los que un anillo de faroles rodea al heroe
const MINUTOS_ANILLO := [2.0, 4.0, 5.5]

var tiempo := 0.0
var heroe
var anillos_hechos := 0

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	$TimerOleada.timeout.connect(generar_oleada)
	$TimerRescate.timeout.connect(generar_rescate)

func _process(delta: float) -> void:
	tiempo += delta
	# Al principio sale una tanda cada 1.2 s; al minuto 6, cada 0.3 s.
	var avance: float = clampf(tiempo / 360.0, 0.0, 1.0)
	$TimerOleada.wait_time = lerpf(1.0, 0.25, avance)
	
	# Hordas especiales
	if anillos_hechos < MINUTOS_ANILLO.size() and tiempo >= MINUTOS_ANILLO[anillos_hechos] * 60.0:
		anillos_hechos += 1
		evento_anillo(18 + anillos_hechos * 6) # 24, 30 y 36 faroles

func generar_oleada() -> void:
	if heroe == null:
		return
	# Minuto 0: 1 yokai por tanda. Minuto 5: 6 por tanda.
	var cantidad: int = 2 + int(tiempo / 50.0)
	for i in cantidad:
		if get_tree().get_nodes_in_group("enemigos").size() >= tope:
			return
		var angulo: float = randf() * TAU
		crear(elegir_yokai(), heroe.global_position + Vector2.RIGHT.rotated(angulo) * distancia)

func elegir_yokai() -> PackedScene:
	var r: float = randf()
	if tiempo > 90.0 and r < 0.08:
		return escena_nurikabe # desde el minuto 2: 6 de cada 100
	if tiempo > 60.0 and r < 0.36:
		return escena_kasa # desde el minuto 1: 3 de cada 10
	return escena_chochin

# TODOS los yokais nuevos pasan por aqui: les sube la vida segun el tiempo.
func crear(escena: PackedScene, posicion: Vector2) -> Yokai:
	var yokai: Yokai = escena.instantiate()
	yokai.vida = int(ceil(yokai.vida * (1.0 + tiempo / 60.0 * vida_extra_por_minuto)))
	add_child(yokai)
	yokai.global_position = dentro_del_mapa(posicion)
	return yokai

# Si el punto cae fuera del mapa, lo trae al borde (antes salian en el vacio y se quedaban quietos)
func dentro_del_mapa(punto: Vector2) -> Vector2:
	var run = get_tree().get_first_node_in_group("run")
	if run == null or not run.limites.has_area():
		return punto
	var margen := Vector2(16, 16)
	return punto.clamp(run.limites.position + margen, run.limites.end - margen)

# Un circulo de faroles alrededor del heroe que se va cerrando
func evento_anillo(cantidad: int) -> void:
	if heroe == null:
		return
	Audio.sfx("viento")
	for i in cantidad:
		var angulo: float = TAU * i / cantidad
		crear(escena_chochin, heroe.global_position + Vector2.RIGHT.rotated(angulo) * 230.0)

func generar_rescate() -> void:
	if escena_rescate == null or heroe == null:
		return
	if get_tree().get_nodes_in_group("rescates").size() > 0:
		return # solo un rescate a la vez
	var rescate: Node2D = escena_rescate.instantiate()
	add_child(rescate)
	# Cerca del heroe, dentro de la pantalla, para que se vea.
	var angulo: float = randf() * TAU
	rescate.global_position = dentro_del_mapa(heroe.global_position + Vector2.RIGHT.rotated(angulo) * randf_range(90.0, 150.0))
