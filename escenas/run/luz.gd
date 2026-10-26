extends Area2D

# La Luz es la experiencia que sueltan los yokais al morir.
# Si el héroe se acerca, vuela hacia él. Al tocarlo, suma experiencia al Run.

@export var valor := 1
const RUTA_DIBUJO := "res://arte/ui/luz.png"
const VELOCIDAD_IMAN := 220.0 # más rápido que el héroe, para que siempre lo alcance

var heroe
var atraida := false
var recogida := false


func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	poner_dibujo()
	# body_entered avisa cuando un cuerpo (el héroe) entra en el círculo.
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if heroe == null:
		return
	# Si el héroe está a menos de su radio de recoger, la luz empieza a volar hacia él.
	if not atraida and global_position.distance_to(heroe.global_position) < heroe.radio_recoger:
		atraida = true
	if atraida:
		global_position = global_position.move_toward(heroe.global_position, VELOCIDAD_IMAN * delta)


func _on_body_entered(cuerpo: Node2D) -> void:
	# "recogida" evita que se cuente dos veces en el mismo cuadro.
	if recogida or not cuerpo.is_in_group("jugador"):
		return
	recogida = true
	var run = get_tree().get_first_node_in_group("run")
	if run:
		run.agregar_experiencia(valor)
	Audio.sfx("luz")
	queue_free()


# Si existe arte/ui/luz.png, la luz se ve como orbe dorado en vez de cuadro.
# La textura se busca una sola vez para todas las luces (sale una por cada yokai que muere).
static var _textura: Texture2D = null
static var _buscada := false

func poner_dibujo() -> void:
	if not _buscada:
		_buscada = true
		_textura = load(RUTA_DIBUJO) if ResourceLoader.exists(RUTA_DIBUJO) else null
	if _textura == null:
		return
	var dibujo := Sprite2D.new()
	dibujo.texture = _textura
	add_child(dibujo)
	for hijo in get_children():
		if hijo is ColorRect:
			hijo.visible = false
