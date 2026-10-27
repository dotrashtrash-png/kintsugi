extends Node2D
# Campana suzu (Miko): onda circular que crece, dana y empuja.

const RECARGA_MINIMA := 1.0 # nunca suena mas rapido que esto
const RADIO_MAXIMO := 80.0 # nunca cubre toda la pantalla

var nivel := 1
var dano := 3
var radio_max := 45.0
var empuje := 12.0
var duracion := 0.35 # lo que tarda la onda en crecer

var radio := 0.0
var golpeados: Array = []
var creciendo := false # solo pega mientras la onda crece
var desvanecer := 1.0 # 1 = onda entera, 0 = ya se deshizo

@onready var timer: Timer = $Timer
@onready var heroe = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	timer.wait_time = 1.8
	timer.timeout.connect(_sonar)

func _sonar() -> void:
	Audio.sfx("campana")
	golpeados.clear()
	creciendo = true
	desvanecer = 1.0
	var tween := create_tween()
	tween.tween_property(self, "radio", radio_max, duracion).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void: creciendo = false)
	tween.tween_property(self, "desvanecer", 0.0, 0.2) # al final se deshace en puntitos
	tween.tween_callback(_apagar)

func _apagar() -> void:
	radio = 0.0
	creciendo = false
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if radio <= 0.0:
		return
	queue_redraw()
	if not creciendo:
		return
	for enemigo in Yokai.todos(get_tree()):
		if not is_instance_valid(enemigo) or enemigo in golpeados:
			continue
		if global_position.distance_to(enemigo.global_position) <= radio:
			golpeados.append(enemigo)
			if not enemigo.is_in_group("jefe"): # al Tengu no se le empuja
				var dir: Vector2 = global_position.direction_to(enemigo.global_position)
				enemigo.global_position += dir * empuje
			enemigo.recibir_dano(int(round(dano * heroe.poder)))
	queue_redraw()

# ---------- Dibujo: onda de sonido en pixel art ----------
# Un anillo doble dorado (el sonido de la campana suzu) con muescas en V entre los dos anillos
# y 4 destellos. Todo se dibuja en cuadritos de 1 px alineados, asi se ve pixel art a cualquier tamano.
const ORO := Color(1.0, 0.82, 0.38)
const CREMA := Color(1.0, 0.95, 0.75)
const BLANCO := Color(1, 1, 1)

func _pixel(p: Vector2, color: Color, lado := 1.0) -> void:
	draw_rect(Rect2(p.round() - Vector2(lado, lado) * 0.5, Vector2(lado, lado)), color)

# Anillo hecho de pixeles; "rompe" (0..1) va dejando huecos para que se deshaga
func _anillo(r: float, color: Color, rompe: float) -> void:
	if r < 1.0:
		return
	var pasos := int(TAU * r * 1.2)
	for i in pasos:
		if rompe > 0.0 and fmod(i * 0.618, 1.0) < rompe:
			continue
		_pixel(Vector2.RIGHT.rotated(TAU * i / pasos) * r, color)

func _draw() -> void:
	if radio <= 0.0:
		return
	var t := radio / radio_max # 0 -> 1 mientras crece
	var rompe := 1.0 - desvanecer # 0 entera, 1 deshecha
	var alfa := 0.35 + 0.65 * desvanecer
	# anillo de afuera (2 px de grueso) y anillo de adentro
	_anillo(radio, Color(ORO, alfa), rompe)
	_anillo(radio - 1.0, Color(ORO, alfa * 0.8), rompe)
	if radio > 9.0:
		_anillo(radio - 5.0, Color(CREMA, alfa * 0.9), minf(1.0, rompe * 1.5))
	# muescas en V entre los dos anillos, 8 alrededor
	if radio > 9.0 and rompe < 0.6:
		for k in 8:
			var a := TAU * k / 8.0 + PI / 8.0
			var d := Vector2.RIGHT.rotated(a)
			var lado := d.orthogonal()
			_pixel(d * (radio - 2.0) + lado, Color(CREMA, alfa))
			_pixel(d * (radio - 2.0) - lado, Color(CREMA, alfa))
			_pixel(d * (radio - 3.0), Color(BLANCO, alfa))
	# 4 destellos en cruz sobre el anillo (arriba, abajo, izquierda, derecha)
	var brillo := clampf(1.0 - absf(t - 0.6) * 2.0, 0.0, 1.0) * desvanecer
	if brillo > 0.05:
		for k in 4:
			var c := Vector2.RIGHT.rotated(TAU * k / 4.0) * radio
			var largo := 1 + int(round(2.0 * brillo))
			for j in range(-largo, largo + 1):
				_pixel(c + Vector2(j, 0), Color(BLANCO, brillo))
				_pixel(c + Vector2(0, j), Color(BLANCO, brillo))
	# al deshacerse suelta puntitos que siguen saliendo
	if rompe > 0.0:
		for k in 12:
			var a := TAU * k / 12.0 + 0.2
			_pixel(Vector2.RIGHT.rotated(a) * (radio + 4.0 * rompe + (k % 3)), Color(CREMA, desvanecer))

# La llama el heroe cuando eligen la campana en el menu de mejoras.
# Todo sube en linea recta y con tope: ya no cubre la pantalla ni suena sin parar.
func subir_nivel() -> void:
	nivel += 1
	dano += 2
	radio_max = minf(RADIO_MAXIMO, radio_max + 5.0)
	timer.wait_time = maxf(RECARGA_MINIMA, timer.wait_time - 0.1)
