extends CharacterBody2D
# El Run escucha esta senal para terminar la partida con victoria.
signal vencido

const ESCENA_CUERVO := preload("res://escenas/enemigos/Cuervo.tscn")
const RUTA_HUMO := "res://escenas/efectos/Humo.tscn"
const RUTA_DIBUJO := "res://arte/yokais/tengu.png"

@export var vida: int = 200
@export var velocidad: float = 35.0
@export var dano: int = 15
@export var fuerza_viento: float = 420.0 # que tan lejos empuja la rafaga
@export var alcance_viento: float = 260.0 # mas lejos que esto, la rafaga no llega

var vida_inicial: int = 0
var heroe
var espera_dano: float = 0.0
var muerto: bool = false
var furioso: bool = false # segunda fase: desde la mitad de la vida
var reloj_cuervos: float = 4.0 # primera invocacion a los 4 s
var reloj_viento: float = 6.0 # primera rafaga a los 6 s

func _ready() -> void:
	add_to_group("enemigos")
	add_to_group("jefe")
	heroe = get_tree().get_first_node_in_group("jugador")
	vida_inicial = vida
	
	$BarraJefe/Barra.max_value = vida
	$BarraJefe/Barra.value = vida
	
	if ResourceLoader.exists(RUTA_DIBUJO):
		$Sprite.texture = load(RUTA_DIBUJO)
		$Sprite.hframes = 2
		$ColorRect.visible = false
	else:
		$Sprite.visible = false
		
	Audio.sfx("tengu")

func _physics_process(delta: float) -> void:
	if heroe == null or muerto:
		return
		
	# Camina hacia el heroe
	velocity = global_position.direction_to(heroe.global_position) * velocidad
	move_and_slide()
	
	if $Sprite.visible:
		$Sprite.frame = int(Time.get_ticks_msec() / 300.0) % 2 # aletea
		
	# Pega por contacto cada 0.8 s
	espera_dano -= delta
	if espera_dano <= 0.0 and global_position.distance_to(heroe.global_position) < 22.0:
		heroe.recibir_dano(dano)
		espera_dano = 0.8
		
	# Ataques con reloj
	reloj_cuervos -= delta
	if reloj_cuervos <= 0.0:
		invocar_cuervos(6 if furioso else 4)
		reloj_cuervos = 5.0 if furioso else 7.0
		
	reloj_viento -= delta
	if reloj_viento <= 0.0:
		rafaga()
		reloj_viento = 3.5 if furioso else 5.5

func invocar_cuervos(cantidad: int) -> void:
	Audio.sfx("cuervo")
	for i in cantidad:
		var cuervo = ESCENA_CUERVO.instantiate()
		get_parent().add_child(cuervo)
		cuervo.global_position = global_position + Vector2.RIGHT.rotated(TAU * i / cantidad) * 24.0

# Aviso de medio segundo (se pone blanco) y despues el viento empuja y pega poquito.
func rafaga() -> void:
	var aviso = create_tween()
	aviso.tween_property(self, "modulate", Color(2, 2, 2), 0.25)
	aviso.tween_property(self, "modulate", Color.WHITE, 0.25)
	await aviso.finished
	
	if muerto or heroe == null:
		return
		
	Audio.sfx("viento")
	if global_position.distance_to(heroe.global_position) < alcance_viento:
		heroe.empujar(global_position.direction_to(heroe.global_position) * fuerza_viento)
		heroe.recibir_dano(5)

func recibir_dano(cantidad: int) -> void:
	if muerto:
		return
	vida -= cantidad
	$BarraJefe/Barra.value = vida
	
	if has_node("Golpe"):
		$Golpe.recibir()
		
	if not furioso and vida <= vida_inicial * 0.5:
		furioso = true
		velocidad *= 1.4
		$BarraJefe/Nombre.text = "Gran Tengu (furioso)"
		
	if vida <= 0:
		morir()

func morir() -> void:
	muerto = true
	$BarraJefe.visible = false
	
	# Los cuervos se deshacen con el jefe
	for cuervo in get_tree().get_nodes_in_group("cuervos"):
		if is_instance_valid(cuervo):
			cuervo.morir()
			
	# Puf grande: 6 humos alrededor
	if ResourceLoader.exists(RUTA_HUMO):
		for i in 6:
			var humo = load(RUTA_HUMO).instantiate()
			get_parent().add_child(humo)
			humo.global_position = global_position + Vector2(randf_range(-18, 18), randf_range(-18, 18))
			
	Audio.sfx("yokai_muere")
	visible = false
	
	# Un momento para ver el puf antes de volver a la aldea
	await get_tree().create_timer(1.2).timeout
	vencido.emit()
	queue_free()
