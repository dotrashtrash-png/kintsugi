extends Node2D

@export var escena_chochin: PackedScene = preload("res://escenas/enemigos/Chochin.tscn")
@export var escena_kasa: PackedScene = preload("res://escenas/enemigos/KasaObake.tscn")
@export var escena_nurikabe: PackedScene = preload("res://escenas/enemigos/Nurikabe.tscn")
@export var escena_rescate: PackedScene = preload("res://escenas/enemigos/Rescate.tscn")
@export var tope: int = 150 # maximo de yokais vivos a la vez (la Web se traba con mas)
@export var distancia: float = 260.0 # a que distancia del heroe aparecen: fuera de la pantalla
@export var vida_extra_por_minuto: float = 0.4 # vida extra que suma cada minuto...
@export var vida_extra_acelerada: float = 0.12 # ...y esta crece al cuadrado: minuto 1 x1.5, minuto 3 x3.3, minuto 5 x6
@export var dano_extra_por_minuto: float = 0.12 # al minuto 5 pegan 60% mas

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

# ---------- Separar la horda ----------
# Los yokais no chocan con fisica (seria muy pesado en la Web). En cambio, cada cuadro
# se reparten en una cuadricula y los que quedan encima de otro se empujan un poco.
# Asi la horda rodea al heroe como en Vampire Survivors en vez de apilarse en un punto.
const SEPARACION := 10.0

func _physics_process(_delta: float) -> void:
	separar()

func separar() -> void:
	var celdas := {}
	for e in get_tree().get_nodes_in_group("enemigos"):
		if e.is_in_group("jefe"):
			continue
		var c := Vector2i(floori(e.global_position.x / SEPARACION), floori(e.global_position.y / SEPARACION))
		if celdas.has(c):
			celdas[c].append(e)
		else:
			celdas[c] = [e]
	for c in celdas:
		var grupo: Array = celdas[c]
		if grupo.size() < 2:
			continue
		for i in grupo.size():
			var a: Node2D = grupo[i]
			for j in range(i + 1, grupo.size()):
				var b: Node2D = grupo[j]
				var d: Vector2 = a.global_position - b.global_position
				var largo := d.length()
				if largo >= SEPARACION:
					continue
				var dir := d / largo if largo > 0.01 else Vector2.RIGHT.rotated(randf() * TAU)
				var paso := dir * (SEPARACION - largo) * 0.25
				a.global_position += paso
				b.global_position -= paso


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
	# El inicio casi no cambia; lo que sube fuerte es el final, cuando ya tienes varias armas.
	var m := tiempo / 60.0
	yokai.vida = int(ceil(yokai.vida * (1.0 + m * vida_extra_por_minuto + m * m * vida_extra_acelerada)))
	yokai.dano = int(round(yokai.dano * (1.0 + m * dano_extra_por_minuto)))
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
