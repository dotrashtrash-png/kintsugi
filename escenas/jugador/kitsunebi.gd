extends Node2D
# Kitsunebi: fuegos de zorro de Kohaku que giran alrededor del heroe
# y queman a los yokais que tocan.

const PAUSA := 0.5 # cada yokai se quema como mucho cada medio segundo

var nivel := 1
var dano := 4
var cantidad := 2 # llamas
var radio := 34.0 # distancia al heroe
var velocidad_giro := 3.0 # radianes por segundo
var angulo := 0.0
var heroe
var quemados := {} # yokai -> segundos que faltan para poder quemarlo otra vez

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")

func _physics_process(delta: float) -> void:
	angulo += velocidad_giro * delta
	# Bajar la espera de cada yokai quemado; olvidar los que ya murieron
	for e in quemados.keys():
		if not is_instance_valid(e):
			quemados.erase(e)
			continue
		quemados[e] -= delta
		if quemados[e] <= 0.0:
			quemados.erase(e)
	# Revisar cada yokai cercano contra las llamas (los lejanos se saltan rapido)
	var llamas: Array[Vector2] = []
	for i in cantidad:
		llamas.append(global_position + posicion_llama(i))
	var alcance := (radio + 11.0) * (radio + 11.0)
	for e in Yokai.todos(get_tree()):
		if not is_instance_valid(e) or quemados.has(e):
			continue
		var p: Vector2 = e.global_position
		if global_position.distance_squared_to(p) > alcance:
			continue
		for pos in llamas:
			if pos.distance_squared_to(p) < 121.0: # 11 px
				e.recibir_dano(int(round(dano * heroe.poder)))
				quemados[e] = PAUSA
				break
	queue_redraw()

func posicion_llama(i: int) -> Vector2:
	return Vector2.RIGHT.rotated(angulo + TAU * i / cantidad) * radio

func _draw() -> void:
	for i in cantidad:
		var p := posicion_llama(i)
		draw_circle(p, 5.0, Color(0.55, 0.85, 1.0, 0.85)) # fuego fatuo azul
		draw_circle(p, 2.5, Color(1, 1, 1)) # centro blanco

# La llama el heroe cuando eligen el kitsunebi en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	cantidad = mini(cantidad + 1, 6)
	dano += 2
	radio += 4.0
