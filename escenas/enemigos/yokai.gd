class_name Yokai
extends CharacterBody2D

# Valores que se cambian en el Inspector de cada yokai.
@export var velocidad := 60.0
@export var vida := 10
@export var dano := 5
@export var probabilidad_material := 0.1 # 0.1 = 1 de cada 10 suelta material
@export var distancia_contacto := 14.0 # distancia minima para pegar
@export var fps := 4.0 # cuadros por segundo de la animacion
@export var voltear := true # voltea el dibujo cuando camina a la izquierda
@export var valor_luz := 1 # experiencia que suelta al morir

const RUTA_LUZ := "res://escenas/run/Luz.tscn"
const RUTA_MATERIAL := "res://escenas/run/Material.tscn"
const RUTA_HUMO := "res://escenas/efectos/Humo.tscn"
const PROBABILIDAD_ONIGIRI := 0.05 # 5 de cada 100 yokais sueltan un onigiri que cura
const PAUSA_DANO := 0.5 # pega cada medio segundo mientras toca al heroe

var heroe
var espera_dano := 0.0
var muerto := false
var reloj_anim := 0.0
var run
var desvio := Vector2.ZERO
var ritmo := 1.0

func _ready() -> void:
	add_to_group("enemigos")
	# Cada yokai apunta a un punto propio alrededor del heroe y camina a su ritmo:
	# asi se reparten en una horda y no se apilan en un solo punto (sin costo de fisica).
	desvio = Vector2.RIGHT.rotated(randf() * TAU) * randf_range(4.0, 13.0)
	ritmo = randf_range(0.85, 1.15)
	heroe = get_tree().get_first_node_in_group("jugador")
	run = get_tree().get_first_node_in_group("run")

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
	move_and_slide()

# Los empujones (campana, golpe) ya no sacan a los yokais del mapa
func quedarse_en_el_mapa() -> void:
	if run and run.limites.has_area():
		global_position = global_position.clamp(run.limites.position, run.limites.end)

func revisar_contacto(delta: float) -> void:
	espera_dano -= delta
	if espera_dano > 0.0:
		return
	if global_position.distance_to(heroe.global_position) < distancia_contacto:
		heroe.recibir_dano(dano)
		espera_dano = PAUSA_DANO

func animar(delta: float) -> void:
	if not has_node("Sprite"):
		return
	var dibujo: Sprite2D = $Sprite
	if dibujo.hframes > 1:
		reloj_anim += delta
		dibujo.frame = int(reloj_anim * fps) % dibujo.hframes
	if voltear and absf(velocity.x) > 1.0:
		dibujo.flip_h = velocity.x < 0.0

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	NumeroDano.crear(self, cantidad)
	if has_node("Golpe"):
		$Golpe.recibir()
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
	soltar(RUTA_HUMO)
	Audio.sfx("yokai_muere")
	queue_free()

func elegir_material() -> String:
	return "madera" if randf() < 0.6 else "tejas"

func soltar(ruta: String):
	if not ResourceLoader.exists(ruta):
		return null
	var cosa: Node2D = load(ruta).instantiate()
	cosa.position = global_position
	get_tree().current_scene.add_child.call_deferred(cosa)
	return cosa
