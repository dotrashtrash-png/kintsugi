extends CharacterBody2D

signal murio

const TIEMPO_INVULNERABLE := 0.4 # tras un golpe, un momento sin recibir dano

var velocidad := 110.0
var vida := 100
var vida_maxima := 100
var radio_recoger := 40.0 # lo usa la Luz de Juan Marin
var regen := 0.0 # vida por segundo (la Miko)
var direccion := Vector2.RIGHT # hacia donde mira; la katana la usa
var empuje := Vector2.ZERO # lo usan el viento del Tengu y el Nurikabe
var muerto := false
var regen_acumulada := 0.0
var invulnerable := 0.0
var paso := 0.0 # para el saltito al caminar

@onready var armas: Node2D = $Armas
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("jugador")
	var datos: Dictionary = Heroes.LISTA[Estado.heroe_elegido]
	vida_maxima = int(datos["vida"] * (1.0 + Estado.bono_vida()))
	vida = vida_maxima
	velocidad = datos["velocidad"]
	radio_recoger = datos["radio"]
	regen = datos.get("regen", 0.0)
	_cargar_sprite(datos.get("sprite", ""))
	agregar_arma(datos["arma"])

# Hojas de Matta: 64x16, 4 cuadros = abajo, arriba, izquierda, derecha
func _cargar_sprite(ruta: String) -> void:
	if ruta == "" or not ResourceLoader.exists(ruta):
		sprite.visible = false # sin dibujo todavia: queda el cuadro azul
		return
	sprite.texture = load(ruta)
	sprite.hframes = 4
	sprite.frame = 0
	sprite.visible = true
	$ColorRect.visible = false

func _physics_process(delta: float) -> void:
	if muerto:
		return
	invulnerable = maxf(0.0, invulnerable - delta)
	var dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = dir * velocidad + empuje
	empuje = empuje.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()
	if dir != Vector2.ZERO:
		direccion = dir
	_animar(dir, delta)
	_regenerar(delta)

func _animar(dir: Vector2, delta: float) -> void:
	if not sprite.visible:
		return
	if dir == Vector2.ZERO:
		paso = 0.0
		sprite.position.y = 0.0
		return
	if absf(dir.x) >= absf(dir.y):
		sprite.frame = 3 if dir.x > 0.0 else 2
	else:
		sprite.frame = 0 if dir.y > 0.0 else 1
	paso += delta * 14.0
	sprite.position.y = -roundf(absf(sin(paso)) * 1.5) # saltito al caminar

func _regenerar(delta: float) -> void:
	if regen <= 0.0 or vida >= vida_maxima:
		return
	regen_acumulada += regen * delta
	if regen_acumulada >= 1.0:
		vida = mini(vida_maxima, vida + 1)
		regen_acumulada -= 1.0

func recibir_dano(cantidad: int) -> void:
	if muerto or invulnerable > 0.0:
		return
	invulnerable = TIEMPO_INVULNERABLE
	vida -= cantidad
	Audio.sfx("dano")
	modulate = Color(1, 0.4, 0.4) # parpadeo rojo
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)
	_sacudir_camara()
	if vida <= 0:
		vida = 0
		muerto = true
		murio.emit()

func _sacudir_camara() -> void:
	var cam: Camera2D = $Camera2D
	var t := create_tween()
	for i in 4:
		t.tween_property(cam, "offset", Vector2(randf_range(-2, 2), randf_range(-2, 2)), 0.03)
	t.tween_property(cam, "offset", Vector2.ZERO, 0.03)

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
