extends Area2D

# Material: madera, tejas u oro. Funciona igual que la Luz.
# El yokai que lo suelta cambia "tipo" antes de agregarlo a la escena.
# (No lleva class_name: "Material" ya es un nombre que usa Godot.)

@export var tipo := "madera"
@export var cantidad := 1

const VELOCIDAD_IMAN := 220.0
const COLORES := {
	"madera": Color(0.8, 0.55, 0.35),
	"tejas": Color(0.9, 0.5, 0.5),
	"oro": Color(1, 0.85, 0.3),
	"onigiri": Color(1, 1, 1),
	"iman": Color(0.8, 0.3, 0.25),
}

var heroe
var atraido := false
var recogido := false


func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	poner_dibujo("res://arte/ui/%s.png" % tipo)
	body_entered.connect(_on_body_entered)
	if tipo == "iman":
		# Late y brilla para que se note entre tanto yokai
		var latido := create_tween().set_loops()
		latido.tween_property(self, "scale", Vector2(1.35, 1.35), 0.35).set_trans(Tween.TRANS_SINE)
		latido.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_SINE)
		modulate = Color(1.3, 1.2, 1.2)


func _physics_process(delta: float) -> void:
	if heroe == null:
		return
	if not atraido and global_position.distance_to(heroe.global_position) < heroe.radio_recoger:
		atraido = true
	if atraido:
		global_position = global_position.move_toward(heroe.global_position, VELOCIDAD_IMAN * delta)


func _on_body_entered(cuerpo: Node2D) -> void:
	if recogido or not cuerpo.is_in_group("jugador"):
		return
	recogido = true
	if tipo == "onigiri":
		cuerpo.vida = mini(cuerpo.vida_maxima, cuerpo.vida + randi_range(20, 30)) # cura, no se guarda
		Audio.sfx("nivel")
		queue_free()
		return
	if tipo == "iman":
		# Imán (muy raro): todas las luces del mapa vuelan al heroe. Solo experiencia.
		for luz in get_tree().get_nodes_in_group("luces"):
			luz.atraer_rapido()
		Audio.sfx("success")
		queue_free()
		return
	var run = get_tree().get_first_node_in_group("run")
	if run:
		run.agregar_material(tipo, cantidad)
	Audio.sfx("material")
	queue_free()


# Si existe el dibujo (arte/ui/madera.png, tejas.png, oro.png), lo pone en vez del cuadro.
# Las texturas se buscan una sola vez y se guardan aqui.
static var _texturas := {}

func poner_dibujo(ruta: String) -> void:
	if not _texturas.has(ruta):
		_texturas[ruta] = load(ruta) if ResourceLoader.exists(ruta) else null
	if _texturas[ruta] == null:
		$Cuadro.color = COLORES.get(tipo, Color.WHITE)
		return
	var dibujo := Sprite2D.new()
	dibujo.texture = _texturas[ruta]
	add_child(dibujo)
	$Cuadro.visible = false
