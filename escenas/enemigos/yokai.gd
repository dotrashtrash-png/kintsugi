class_name Yokai
extends CharacterBody2D

# Valores que se cambian en el Inspector de cada yokai.
@export var velocidad := 60.0
@export var vida := 10
@export var dano := 5
@export var probabilidad_material := 0.05 # 0.05 = 1 de cada 20 suelta material
@export var distancia_contacto := 14.0 # distancia minima para pegar
@export var fps := 4.0 # cuadros por segundo de la animacion
@export var voltear := true # voltea el dibujo cuando camina a la izquierda
@export var valor_luz := 1 # experiencia que suelta al morir

const RUTA_LUZ := "res://escenas/run/Luz.tscn"
const RUTA_MATERIAL := "res://escenas/run/Material.tscn"
const RUTA_HUMO := "res://escenas/efectos/Humo.tscn"
const PROBABILIDAD_ONIGIRI := 0.025 # 25 de cada 1000 yokais sueltan un onigiri que cura
const PROBABILIDAD_IMAN := 0.002 # 2 de cada 1000: un iman que atrae todas las luces del mapa
const PAUSA_DANO := 0.5 # pega cada medio segundo mientras toca al heroe

# Lista de enemigos compartida por cuadro: las armas la piden muchas
# veces por cuadro y pedirla al arbol cada vez era lo que mas lag daba en la Web.
static var _lista_enemigos: Array = []
static var _cuadro_lista := -1

static func todos(arbol: SceneTree) -> Array:
	if arbol == null:
		return []
	# Godot borra los nodos (queue_free) despues de CADA paso de fisica y de cada cuadro,
	# asi que la lista guardada puede traer yokais ya borrados: si hay uno, se pide de nuevo.
	var cuadro := Engine.get_physics_frames()
	var vieja := cuadro != _cuadro_lista
	if not vieja:
		for e in _lista_enemigos:
			if not is_instance_valid(e):
				vieja = true
				break
	if vieja:
		_lista_enemigos = arbol.get_nodes_in_group("enemigos")
		_cuadro_lista = cuadro
	return _lista_enemigos

var heroe
var espera_dano := 0.0
var muerto := false
var reloj_anim := 0.0
var run
var desvio := Vector2.ZERO
var ritmo := 1.0
# Guardados una vez en _ready: pedirlos 150 veces por cuadro pesaba en la Web
var dibujo: Sprite2D = null
var golpe: Node = null
var limites := Rect2()
var contacto2 := 0.0 # distancia de contacto al cuadrado

func _ready() -> void:
	add_to_group("enemigos")
	# Cada yokai apunta a un punto propio alrededor del heroe y camina a su ritmo:
	# asi se reparten en una horda y no se apilan en un solo punto (sin costo de fisica).
	desvio = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(4.0, 13.0)
	ritmo = randf_range(0.85, 1.15)
	heroe = get_tree().get_first_node_in_group("jugador")
	run = get_tree().get_first_node_in_group("run")
	dibujo = get_node_or_null("Sprite") as Sprite2D
	golpe = get_node_or_null("Golpe")
	if run:
		limites = run.limites
	contacto2 = distancia_contacto * distancia_contacto

func _physics_process(delta: float) -> void:
	if heroe == null or muerto:
		return
	mover(delta)
	quedarse_en_el_mapa()
	revisar_contacto(delta)
	animar(delta)

# A donde camina este yokai: el heroe mas su desvio propio
func objetivo() -> Vector2:
	return heroe.global_position + desvio

func mover(_delta: float) -> void:
	velocity = global_position.direction_to(objetivo()) * velocidad * ritmo
	avanzar()

# Los yokais no chocan con nada (collision_mask = 0): moverlos a mano es igual que
# move_and_slide() pero mucho mas barato con 150 en pantalla (era lo que mas pesaba al final).
func avanzar() -> void:
	global_position += velocity * get_physics_process_delta_time()

# Los empujones (campana, golpe) ya no sacan a los yokais del mapa
func quedarse_en_el_mapa() -> void:
	if limites.has_area():
		global_position = global_position.clamp(limites.position, limites.end)

func revisar_contacto(delta: float) -> void:
	espera_dano -= delta
	if espera_dano > 0.0:
		return
	if global_position.distance_squared_to(heroe.global_position) < contacto2:
		heroe.recibir_dano(dano) # el poder del heroe (Hachimaki) sube SU dano, no el de los yokais
		espera_dano = PAUSA_DANO

func animar(delta: float) -> void:
	if dibujo == null:
		return
	if dibujo.hframes > 1:
		reloj_anim += delta
		var cuadro := int(reloj_anim * fps) % dibujo.hframes
		if cuadro != dibujo.frame:
			dibujo.frame = cuadro
	if voltear and absf(velocity.x) > 1.0:
		var izquierda := velocity.x < 0.0
		if izquierda != dibujo.flip_h:
			dibujo.flip_h = izquierda

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	NumeroDano.crear(self, cantidad)
	if golpe:
		golpe.recibir()
	if vida <= 0:
		morir()

func morir() -> void:
	muerto = true
	var luz = soltar(RUTA_LUZ)
	if luz:
		luz.valor = valor_luz
	if randf() < probabilidad_material:
		var mat = soltar(RUTA_MATERIAL)
		if mat:
			mat.tipo = elegir_material()
	if randf() < PROBABILIDAD_ONIGIRI:
		var comida = soltar(RUTA_MATERIAL)
		if comida:
			comida.tipo = "onigiri"
	elif randf() < PROBABILIDAD_IMAN and get_tree().get_nodes_in_group("imanes").is_empty():
		var iman = soltar(RUTA_MATERIAL)
		if iman:
			iman.tipo = "iman"
			iman.add_to_group("imanes") # nunca hay dos en el mapa a la vez
	# Si muchos mueren a la vez, no hace falta un humo por cada uno (eran lo que mas pesaba)
	if humos_vivos < MAXIMO_HUMOS:
		var humo = soltar(RUTA_HUMO)
		if humo:
			humos_vivos += 1
			humo.tree_exited.connect(func() -> void: Yokai.humos_vivos -= 1)
	Audio.sfx("yokai_muere")
	queue_free()

func elegir_material() -> String:
	return "madera" if randf() < 0.6 else "tejas"

# Las escenas que sueltan se cargan una sola vez (antes se buscaban en disco en cada muerte)
const MAXIMO_HUMOS := 12
static var humos_vivos := 0
static var _escenas := {}

func soltar(ruta: String):
	if not _escenas.has(ruta):
		_escenas[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	var escena: PackedScene = _escenas[ruta]
	if escena == null:
		return null
	var cosa: Node2D = escena.instantiate()
	cosa.position = global_position
	get_tree().current_scene.add_child.call_deferred(cosa)
	return cosa
