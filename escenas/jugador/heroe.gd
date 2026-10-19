extends CharacterBody2D

signal murio

var velocidad := 110.0
var vida := 100
var vida_maxima := 100
var direccion := Vector2.RIGHT # hacia donde mira; la katana la usa
var empuje := Vector2.ZERO # lo usan el viento del Tengu y el Nurikabe
var muerto := false

func _ready() -> void:
	add_to_group("jugador")
	var datos: Dictionary = Heroes.LISTA[Estado.heroe_elegido]
	vida_maxima = datos["vida"]
	vida = vida_maxima
	velocidad = datos["velocidad"]

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = dir * velocidad + empuje
	empuje = empuje.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()
	if dir != Vector2.ZERO:
		direccion = dir

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	print("Vida del heroe: ", vida)
	if vida <= 0:
		muerto = true
		murio.emit()
		print("El heroe murio")

func empujar(fuerza: Vector2) -> void:
	empuje += fuerza
