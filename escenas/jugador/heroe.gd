extends CharacterBody2D

signal murio

var velocidad := 110.0
var vida := 100
var vida_maxima := 100
var radio_recoger := 40.0 # lo usa la Luz de Juan Marin
var direccion := Vector2.RIGHT # hacia donde mira; la katana la usa
var empuje := Vector2.ZERO # lo usan el viento del Tengu y el Nurikabe
var muerto := false

@onready var armas: Node2D = $Armas

func _ready() -> void:
	add_to_group("jugador")
	var datos: Dictionary = Heroes.LISTA[Estado.heroe_elegido]
	vida_maxima = int(datos["vida"] * (1.0 + Estado.bono_vida()))
	vida = vida_maxima
	velocidad = datos["velocidad"]
	radio_recoger = datos["radio"]
	agregar_arma(datos["arma"])

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

# Agrega un arma buscando su escena por nombre: "katana" -> Katana.tscn
func agregar_arma(nombre: String) -> void:
	var ruta := "res://escenas/jugador/%s.tscn" % nombre.capitalize()
	if not ResourceLoader.exists(ruta):
		push_warning("Todavia no existe el arma: " + ruta)
		return
	var arma: Node = load(ruta).instantiate()
	arma.name = nombre
	armas.add_child(arma)

# Juan Marin la llama desde el menu de mejoras con un nombre de Heroes.MEJORAS
func mejorar(nombre: String) -> void:
	match nombre:
		"waraji":
			velocidad *= 1.1
		"haori":
			vida_maxima += 20
			vida += 20
		"omamori":
			radio_recoger *= 1.2
		_:
			if armas.has_node(nombre):
				armas.get_node(nombre).subir_nivel()
			else:
				agregar_arma(nombre)
				
