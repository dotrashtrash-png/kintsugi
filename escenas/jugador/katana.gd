extends Area2D
# Katana (Ronin): corte al frente cada cierto tiempo.

const RECARGA_MINIMA := 0.5 # nunca ataca mas rapido que esto
const ALCANCE_APUNTAR := 70.0 # apunta sola al yokai mas cercano dentro de esta distancia

const ESCALA_INICIAL := 1.15 # un poco mas grande desde el inicio
const ESCALA_MAXIMA := 1.8 # tope: nunca se vuelve gigante

var nivel := 1
var dano := 7 # antes 5 (+2 por nivel): con kunais ya no valia la pena subirla
var heroe
var mostrando := false

@onready var timer: Timer = $Timer

func _ready() -> void:
	heroe = get_tree().get_first_node_in_group("jugador")
	scale = Vector2.ONE * ESCALA_INICIAL
	timer.timeout.connect(_atacar)

func _physics_process(_delta: float) -> void:
	if heroe == null or mostrando:
		return # durante el corte la direccion queda fija (antes se podia girar y pegar en 360)
	var objetivo := yokai_mas_cercano()
	if objetivo:
		rotation = global_position.direction_to(objetivo.global_position).angle()
	else:
		rotation = heroe.direccion.angle() # sin yokais cerca: hacia donde camina

func yokai_mas_cercano() -> Node2D:
	var mejor: Node2D = null
	var mejor_distancia := ALCANCE_APUNTAR * scale.x
	for e in Yokai.todos(get_tree()):
		var d := global_position.distance_to(e.global_position)
		if d < mejor_distancia:
			mejor = e
			mejor_distancia = d
	return mejor

func _atacar() -> void:
	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("enemigos"):
			cuerpo.recibir_dano(int(round(dano * heroe.poder)))
	Audio.sfx("katana")
	mostrando = true
	sentido = -sentido # un corte de arriba a abajo, el siguiente de abajo a arriba
	var t := create_tween()
	t.tween_method(_poner_progreso, 0.0, 1.0, DURACION_CORTE)
	t.tween_callback(_ocultar)

func _poner_progreso(p: float) -> void:
	progreso = p
	queue_redraw()

func _ocultar() -> void:
	mostrando = false
	queue_redraw()

# El corte: una media luna que barre de un lado al otro, gruesa en la punta y que se
# va cerrando por detras, con el filo blanco y unas chispas al final.
const DURACION_CORTE := 0.18
const RADIO_CORTE := 20.0
const ABERTURA := 1.25 # radianes a cada lado (unos 72 grados)
const CENTRO_CORTE := Vector2(4, 0)
var progreso := 0.0
var sentido := 1.0

func _draw() -> void:
	if not mostrando:
		return
	var a0 := -ABERTURA * sentido
	var a1 := ABERTURA * sentido
	var barrido := 1.0 - pow(1.0 - minf(progreso * 1.4, 1.0), 3.0) # rapido al inicio, frena al final
	var punta := lerpf(a0, a1, barrido)
	var cola := lerpf(a0, a1, maxf(0.0, (progreso - 0.3) / 0.7)) # la cola alcanza a la punta
	var alfa := 1.0 if progreso < 0.6 else 1.0 - (progreso - 0.6) / 0.4
	var pasos := 14
	var afuera := PackedVector2Array()
	var adentro := PackedVector2Array()
	for i in pasos + 1:
		var f := float(i) / pasos
		var ang := lerpf(cola, punta, f)
		var grosor := 1.0 + 7.0 * f # fina en la cola, gruesa en la punta
		var dir := Vector2.RIGHT.rotated(ang)
		afuera.append(CENTRO_CORTE + dir * RADIO_CORTE)
		adentro.append(CENTRO_CORTE + dir * (RADIO_CORTE - grosor))
	if absf(punta - cola) > 0.05:
		var cuerpo := afuera.duplicate()
		for i in range(adentro.size() - 1, -1, -1):
			cuerpo.append(adentro[i])
		draw_colored_polygon(cuerpo, Color(1.0, 0.95, 0.85, 0.45 * alfa))
		draw_polyline(afuera, Color(1, 1, 1, 0.95 * alfa), 2.0) # el filo
	# Linea de la hoja en la punta y chispas
	var d := Vector2.RIGHT.rotated(punta)
	draw_line(CENTRO_CORTE + d * (RADIO_CORTE - 9.0), CENTRO_CORTE + d * (RADIO_CORTE + 3.0), Color(1, 1, 1, alfa), 2.0)
	if progreso > 0.45:
		var chispa := (progreso - 0.45) / 0.55
		for k in 3:
			var off := Vector2.RIGHT.rotated(punta + sentido * (0.25 + 0.2 * k))
			var p0 := CENTRO_CORTE + off * (RADIO_CORTE + 2.0 + 6.0 * chispa)
			draw_rect(Rect2(p0 - Vector2.ONE, Vector2(2, 2)), Color(1.0, 0.85, 0.45, 1.0 - chispa))

# La llama el heroe cuando eligen la katana en el menu de mejoras.
# Crece en linea recta hasta el tope: al nivel 8 llega a 1.8 (antes 1.7) y pega 28 (antes 19).
func subir_nivel() -> void:
	nivel += 1
	dano += 3
	scale = Vector2.ONE * minf(ESCALA_MAXIMA, ESCALA_INICIAL + 0.1 * (nivel - 1))
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time - 0.04)
