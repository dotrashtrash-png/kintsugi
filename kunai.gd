extends Node2D
# Kunai (Kunoichi): lanza cuchillos al yokai mas cercano. Atraviesan yokais.
# Si no hay ninguno cerca, los lanza hacia donde mira el heroe.
const CUCHILLO := preload("res://escenas/jugador/Cuchillo.tscn")
const ABANICO := 0.18 # radianes entre un cuchillo y el siguiente
const ALCANCE := 230.0 # el cuchillo recorre unos 290 px (320 x 0.9 s): apunta solo a lo que alcanza
var nivel := 1
var dano := 5.5 # antes 7 y luego 6: sigue un poco fuerte frente a la katana
var cantidad := 1
var heroe
@onready var timer: Timer = $Timer

const RECARGA_INICIAL := 1.1 # antes 0.9: era una escopeta andante
const RECARGA_MINIMA := 0.6 # antes 0.35
const CANTIDAD_MAXIMA := 4 # cuchillos por tanda como mucho

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	timer.wait_time = RECARGA_INICIAL
	timer.timeout.connect(_lanzar)

func _lanzar() -> void:
	if heroe == null:
		return
	var base: Vector2 = _apuntar()
	Audio.sfx("kunai")
	for i in cantidad:
		var c = CUCHILLO.instantiate()
		# Si son varios, salen en abanico centrado en el objetivo
		c.direccion = base.rotated((i - (cantidad - 1) / 2.0) * ABANICO)
		c.dano = int(round(dano * heroe.poder))
		get_tree().current_scene.add_child(c)
		c.global_position = global_position

# Direccion hacia el yokai vivo mas cercano dentro del alcance
func _apuntar() -> Vector2:
	var mejor: Node2D = null
	var mejor_dist := ALCANCE * ALCANCE
	for e in Yokai.todos(get_tree()):
		if not is_instance_valid(e) or not (e is Node2D):
			continue
		if "muerto" in e and e.muerto:
			continue
		var d := global_position.distance_squared_to(e.global_position)
		if d < mejor_dist:
			mejor_dist = d
			mejor = e
	if mejor:
		return global_position.direction_to(mejor.global_position)
	var mira: Vector2 = heroe.direccion
	return mira.normalized() if mira != Vector2.ZERO else Vector2.RIGHT

# La llama el heroe cuando eligen el kunai en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	dano += 1.5
	if nivel % 2 == 0:
		cantidad = mini(CANTIDAD_MAXIMA, cantidad + 1) # un cuchillo mas cada 2 niveles
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time * 0.92)
