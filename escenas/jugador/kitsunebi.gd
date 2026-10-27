extends Node2D
# Kitsunebi: fuegos de zorro de Kohaku que giran alrededor del heroe
# y queman a los yokais que tocan.
# Van en ciclos: arden un rato, se apagan, descansan y vuelven a encenderse.
# Pegan mas que antes, pero no estan siempre: queda casi igual de fuerte y se ve mejor.

const PAUSA := 0.5 # cada yokai se quema como mucho cada medio segundo
const LLAMA := preload("res://arte/ui/kitsunebi_llama.png") # 4 cuadros de 12x14
const CUADROS := 4
const ANCHO := 12
const ALTO := 14
const ENCENDIDO := 3.5 # segundos ardiendo
const DESCANSO := 2.0 # segundos apagado
const FUNDIDO := 0.3 # lo que tarda en aparecer o desaparecer

var nivel := 1
var dano := 6 # antes 4 (+2 por nivel), pero siempre encendido
var cantidad := 2 # llamas
var radio := 34.0 # distancia al heroe
var velocidad_giro := 3.0 # radianes por segundo
var angulo := 0.0
var heroe
var quemados := {} # yokai -> segundos que faltan para poder quemarlo otra vez
var reloj := 0.0 # tiempo dentro del ciclo encendido + descanso
var brillo := 0.0 # 0 = apagado, 1 = encendido (para el fundido)
var cuadro_fisica := 0
var reloj_anim := 0.0


func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")


func _physics_process(delta: float) -> void:
	angulo += velocidad_giro * delta
	reloj_anim += delta
	reloj = fmod(reloj + delta, ENCENDIDO + DESCANSO)
	# brillo: sube al empezar, baja al final de ENCENDIDO, 0 durante el descanso
	if reloj < ENCENDIDO:
		brillo = minf(1.0, minf(reloj, ENCENDIDO - reloj) / FUNDIDO)
	else:
		brillo = 0.0
	queue_redraw()
	# Bajar la espera de cada yokai quemado; olvidar los que ya murieron
	for e in quemados.keys():
		if not is_instance_valid(e):
			quemados.erase(e)
			continue
		quemados[e] -= delta
		if quemados[e] <= 0.0:
			quemados.erase(e)
	# Solo queman cuando estan casi encendidas, y se revisa cada 2 cuadros (cuesta la mitad)
	cuadro_fisica += 1
	if brillo < 0.6 or cuadro_fisica % 2 != 0:
		return
	var llamas: Array[Vector2] = []
	for i in cantidad:
		llamas.append(global_position + posicion_llama(i))
	var alcance := (radio + 12.0) * (radio + 12.0)
	for e in Yokai.todos(get_tree()):
		if not is_instance_valid(e) or quemados.has(e):
			continue
		var p: Vector2 = e.global_position
		if global_position.distance_squared_to(p) > alcance:
			continue
		for pos in llamas:
			if pos.distance_squared_to(p) < 144.0: # 12 px
				e.recibir_dano(int(round(dano * heroe.poder)))
				quemados[e] = PAUSA
				break


func posicion_llama(i: int) -> Vector2:
	return Vector2.RIGHT.rotated(angulo + TAU * i / cantidad) * radio


func _draw() -> void:
	if brillo <= 0.0:
		return
	var tam := Vector2(ANCHO, ALTO) * (0.6 + 0.4 * brillo) # crecen al encenderse
	for i in cantidad:
		var p := posicion_llama(i)
		var cuadro := (int(reloj_anim * 10.0) + i) % CUADROS # cada llama parpadea a destiempo
		var fuente := Rect2(cuadro * ANCHO, 0, ANCHO, ALTO)
		# halo suave detras
		draw_circle(p, 7.0 * brillo, Color(0.45, 0.7, 1.0, 0.25 * brillo))
		draw_texture_rect_region(LLAMA, Rect2(p - Vector2(tam.x / 2.0, tam.y * 0.65), tam), fuente, Color(1, 1, 1, brillo))


# La llama el heroe cuando eligen el kitsunebi en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	cantidad = mini(cantidad + 1, 6)
	dano += 3
	radio += 4.0
