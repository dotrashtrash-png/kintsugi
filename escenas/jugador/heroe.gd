extends CharacterBody2D

signal murio

var velocidad := 110.0
var vida := 100
var vida_maxima := 100
var radio_recoger := 40.0 # lo usa la Luz de Juan Marin
var regen := 0.0 # vida por segundo (la Miko)
var direccion := Vector2.RIGHT # hacia donde mira; la katana la usa
var empuje := Vector2.ZERO # lo usan el viento del Tengu y el Nurikabe
var muerto := false
var regen_acumulada := 0.0

@onready var armas: Node2D = $Armas

func _ready() -> void:
	add_to_group("jugador")
	var datos: Dictionary = Heroes.LISTA[Estado.heroe_elegido]
	vida_maxima = int(datos["vida"] * (1.0 + Estado.bono_vida()))
	vida = vida_maxima
	velocidad = datos["velocidad"]
	radio_recoger = datos["radio"]
	regen = datos.get("regen", 0.0)
	agregar_arma(datos["arma"])

func _physics_process(delta: float) -> void:
	if muerto:
		return
	var dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = dir * velocidad + empuje
	empuje = empuje.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()
	if dir != Vector2.ZERO:
		direccion = dir
	# Cuando Matta entregue el sprite (nodo "Sprite"), mira hacia donde camina
	if dir.x != 0.0 and has_node("Sprite"):
		$Sprite.flip_h = dir.x < 0.0
	_regenerar(delta)

func _regenerar(delta: float) -> void:
	if regen <= 0.0 or vida >= vida_maxima:
		return
	regen_acumulada += regen * delta
	if regen_acumulada >= 1.0:
		vida = mini(vida_maxima, vida + 1)
		regen_acumulada -= 1.0

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	Audio.sfx("dano")
	modulate = Color(1, 0.4, 0.4) # parpadeo rojo
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	if vida <= 0:
		vida = 0
		muerto = true
		murio.emit()

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

# Juan Marin la llama desde el menu de mejoras con una clave de Heroes.MEJORAS
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
