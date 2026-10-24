extends CharacterBody2D

signal murio

const TIEMPO_INVULNERABLE := 0.4 # tras un golpe, un momento sin recibir dano
const NIVEL_MAXIMO := 8 # ninguna mejora pasa de nivel 8 (el Run usa el mismo numero)
# Orden de los cuadros en la hoja del heroe (64x16)
const CUADRO := {"abajo": 0, "arriba": 1, "izquierda": 2, "derecha": 3}
const VELOCIDAD_MAXIMA := 170.0 # con el Waraji nunca pasa de aqui (evita bugs de choque)
const EMPUJE_MAXIMO := 450.0 # el viento y el Nurikabe no lo lanzan mas lejos que esto
# Los bordes del mapa los pone el Run (calcular_limites), no el heroe.

var velocidad := 110.0
var vida := 100
var vida_maxima := 100
var radio_recoger := 40.0 # lo usan la Luz y el Material
var regen := 0.0 # vida por segundo (la Miko)
var poder := 1.0 # multiplica el dano de TODAS las armas (sube con el Hachimaki)
var direccion := Vector2.RIGHT # hacia donde mira; la katana y el kunai la usan
var empuje := Vector2.ZERO # lo usan el viento del Tengu y el Nurikabe
var muerto := false
var regen_acumulada := 0.0
var invulnerable := 0.0
var paso := 0.0 # para el saltito al caminar
var niveles := {} # nivel de las pasivas, por ejemplo {"waraji": 2}
var velocidad_base := 110.0
var radio_base := 40.0

@onready var armas: Node2D = $Armas
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("jugador")
	var datos: Dictionary = Heroes.LISTA[Estado.heroe_elegido]
	vida_maxima = int(datos["vida"] * (1.0 + Estado.bono_vida()))
	vida = vida_maxima
	velocidad = datos["velocidad"]
	velocidad_base = velocidad
	radio_recoger = datos["radio"]
	radio_base = radio_recoger
	regen = datos.get("regen", 0.0)
	_cargar_sprite(datos.get("sprite", ""))
	agregar_arma(datos["arma"])

# Si el heroe ya tiene dibujo, lo pone y esconde el cuadro azul.
func _cargar_sprite(ruta: String) -> void:
	if ruta == "" or not ResourceLoader.exists(ruta):
		sprite.visible = false # sin dibujo todavia: queda el cuadro azul
		return
	sprite.texture = load(ruta)
	sprite.hframes = 4
	sprite.frame = CUADRO["abajo"]
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

# Elige el cuadro segun hacia donde camina y hace el saltito de los pasos.
func _animar(dir: Vector2, delta: float) -> void:
	if not sprite.visible:
		return
	if dir == Vector2.ZERO:
		paso = 0.0
		sprite.position.y = 0.0
		return
	if absf(dir.x) >= absf(dir.y):
		sprite.frame = CUADRO["derecha"] if dir.x > 0.0 else CUADRO["izquierda"]
	else:
		sprite.frame = CUADRO["abajo"] if dir.y > 0.0 else CUADRO["arriba"]
	paso += delta * 14.0
	sprite.position.y = -roundf(absf(sin(paso)) * 1.5) # saltito al caminar

# Barra de vida chiquita debajo del heroe (como en Vampire Survivors)
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if muerto:
		return
	var ancho := 16.0
	var y := 10.0
	draw_rect(Rect2(-ancho / 2.0 - 1.0, y - 1.0, ancho + 2.0, 4.0), Color("1b1a2e"))
	draw_rect(Rect2(-ancho / 2.0, y, ancho * float(vida) / float(vida_maxima), 2.0), Color("c8402e"))

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
	empuje = (empuje + fuerza).limit_length(EMPUJE_MAXIMO)

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
# Las pasivas suben sobre el valor BASE del heroe (en linea recta, no se multiplican).
func mejorar(nombre: String) -> void:
	if nivel_de(nombre) >= NIVEL_MAXIMO:
		return # ya esta al maximo
	match nombre:
		"waraji":
			velocidad = minf(VELOCIDAD_MAXIMA, velocidad + velocidad_base * 0.08)
		"haori":
			vida_maxima += 25
			vida = mini(vida_maxima, vida + 25)
		"omamori":
			radio_recoger += radio_base * 0.25
		"hachimaki":
			poder += 0.2
		_:
			# Es un arma: si ya la tiene, sube de nivel; si no, la agrega
			if armas.has_node(nombre):
				armas.get_node(nombre).subir_nivel()
			else:
				agregar_arma(nombre)
			return
	niveles[nombre] = niveles.get(nombre, 0) + 1

# 0 = no la tiene. El Run la usa para no ofrecer lo que ya llego a NIVEL_MAXIMO,
# y el menu para mostrar "(nueva)" o "Nv. 3".
func nivel_de(nombre: String) -> int:
	if armas.has_node(nombre):
		return armas.get_node(nombre).nivel
	return niveles.get(nombre, 0)
