extends Area2D

const TIEMPO_PARA_LIBERAR := 3.0
const ORO_POR_RESCATE := 2

var heroe_dentro := false
var progreso := 0.0
var liberado := false
var emboscada_hecha := false
const KASAS_EMBOSCADA := 6 # al empezar a liberar, salen paraguas alrededor

func _ready() -> void:
	add_to_group("rescates")
	poner_dibujo()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = true
		if not emboscada_hecha:
			emboscada_hecha = true
			emboscada.call_deferred() # no se puede crear cuerpos en medio de la fisica

func _on_body_exited(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("jugador"):
		heroe_dentro = false

func _process(delta: float) -> void:
	if liberado:
		return
	if heroe_dentro:
		progreso += delta
	else:
		progreso = maxf(0.0, progreso - delta * 0.5) # si sales, la barra baja despacio
	
	$Barra.value = progreso / TIEMPO_PARA_LIBERAR * 100.0
	
	if progreso >= TIEMPO_PARA_LIBERAR:
		liberar()

func liberar() -> void:
	liberado = true
	Audio.sfx("rescate")
	var run = get_tree().get_first_node_in_group("run")
	if run:
		run.agregar_aldeano()
		run.agregar_material("oro", ORO_POR_RESCATE)
	queue_free()

# Si existe arte/aldea/aldeano.png (hoja de 64x16), el aldeano sale dibujado de frente.
func poner_dibujo() -> void:
	var ruta := "res://arte/aldea/aldeano.png"
	if not ResourceLoader.exists(ruta):
		return
	var dibujo := Sprite2D.new()
	dibujo.texture = load(ruta)
	dibujo.hframes = 4
	dibujo.frame = 0
	dibujo.position = $Aldeano.position + $Aldeano.size / 2.0
	add_child(dibujo)
	move_child(dibujo, $Barra.get_index()) # debajo de la barra
	$Aldeano.visible = false

# Los yokais no dejan rescatar tranquilo: aparece un circulo de Kasas
func emboscada() -> void:
	var spawner = get_parent()
	if spawner == null or not spawner.has_method("crear"):
		return
	for i in KASAS_EMBOSCADA:
		var punto: Vector2 = global_position + Vector2.RIGHT.rotated(TAU * i / KASAS_EMBOSCADA) * 110.0
		spawner.crear(spawner.escena_kasa, punto)
