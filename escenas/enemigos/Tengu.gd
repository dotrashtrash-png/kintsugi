extends CharacterBody2D

# El Run de Juan Marín escucha esta señal para terminar la partida con victoria.
signal vencido

@export var vida := 200
@export var velocidad := 35.0
@export var dano := 15

var heroe
var espera_dano := 0.0
var muerto := false

func _ready() -> void:
	add_to_group("enemigos")
	add_to_group("jefe")
	heroe = get_tree().get_first_node_in_group("jugador")
	Audio.sfx("tengu")

func _physics_process(delta: float) -> void:
	if heroe == null or muerto:
		return
	# Camina derecho hacia el héroe, lento.
	velocity = global_position.direction_to(heroe.global_position) * velocidad
	move_and_slide()
	# Pega cada 0.8 s mientras esté cerca (no en cada cuadro).
	espera_dano -= delta
	if espera_dano <= 0.0 and global_position.distance_to(heroe.global_position) < 22.0:
		heroe.recibir_dano(dano)
		espera_dano = 0.8

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	if has_node("Golpe"):
		$Golpe.recibir()
	if vida <= 0:
		muerto = true
		vencido.emit()
		queue_free()
