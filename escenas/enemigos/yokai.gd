class_name Yokai
extends CharacterBody2D

# Valores que se cambian en el Inspector de cada yokai.
@export var velocidad := 60.0
@export var vida := 10
@export var dano := 5
@export var probabilidad_material := 1.0 # 0.1 = 1 de cada 10 suelta material
@export var distancia_contacto := 14.0 # qué tan cerca tiene que estar para pegar

const RUTA_LUZ := "res://escenas/run/Luz.tscn"
const RUTA_MATERIAL := "res://escenas/run/Material.tscn"
const RUTA_HUMO := "res://escenas/efectos/Humo.tscn"
const PAUSA_DANO := 0.5 # pega cada medio segundo mientras toca al héroe, no cada cuadro

var heroe
var espera_dano := 0.0
var muerto := false

func _ready() -> void:
	add_to_group("enemigos")
	heroe = get_tree().get_first_node_in_group("jugador")

func _physics_process(delta: float) -> void:
	if heroe == null or muerto:
		return
	mover(delta)
	revisar_contacto(delta)

# Movimiento normal: ir derecho al héroe. La Kasa reemplaza esta función.
func mover(_delta: float) -> void:
	velocity = global_position.direction_to(heroe.global_position) * velocidad
	move_and_slide()

func revisar_contacto(delta: float) -> void:
	espera_dano -= delta
	if espera_dano > 0.0:
		return
	if global_position.distance_to(heroe.global_position) < distancia_contacto:
		heroe.recibir_dano(dano)
		espera_dano = PAUSA_DANO

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	# Golpe es el componente de Villa: parpadeo blanco y empujón.
	if has_node("Golpe"):
		$Golpe.recibir()
	if vida <= 0:
		morir()

func morir() -> void:
	muerto = true
	soltar(RUTA_LUZ)
	if randf() < probabilidad_material:
		var mat = soltar(RUTA_MATERIAL)
		if mat:
			mat.tipo = elegir_material()
	soltar(RUTA_HUMO)
	Audio.sfx("yokai_muere")
	queue_free()

# Chōchin y Kasa sueltan madera o tejas. El Nurikabe cambiará esto por oro.
func elegir_material() -> String:
	return "madera" if randf() < 0.6 else "tejas"

# Crea una escena (luz, material o humo) donde murió el yokai.
# Si la escena todavía no existe, no hace nada: así no dependes de que los demás terminen.
func soltar(ruta: String):
	if not ResourceLoader.exists(ruta):
		return null
	var cosa: Node2D = load(ruta).instantiate()
	cosa.position = global_position
	# call_deferred: se agrega al terminar el cuadro (Godot no deja agregar en medio de la física).
	get_tree().current_scene.add_child.call_deferred(cosa)
	return cosa
