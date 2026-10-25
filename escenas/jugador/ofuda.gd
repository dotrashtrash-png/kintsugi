extends Node2D
# Ofuda (Onmyoji): lanza talismanes hacia los yokais mas cercanos.

const TALISMAN := preload("res://escenas/jugador/Talisman.tscn")

var nivel := 1
var dano := 6
var cantidad := 1 # talismanes por disparo
var alcance := 220.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_lanzar)

func _lanzar() -> void:
	var objetivos := _mas_cercanos(cantidad)
	if objetivos.is_empty():
		return
	Audio.sfx("ofuda")
	for objetivo in objetivos:
		var t = TALISMAN.instantiate()
		t.objetivo = objetivo
		t.dano = dano
		get_tree().current_scene.add_child(t)
		t.global_position = global_position

func _mas_cercanos(n: int) -> Array:
	var lista: Array = []
	for e in Yokai.todos(get_tree()):
		var d := global_position.distance_to(e.global_position)
		if d <= alcance:
			lista.append([d, e])
	lista.sort_custom(func(a, b): return a[0] < b[0])
	var resultado: Array = []
	for i in mini(n, lista.size()):
		resultado.append(lista[i][1])
	return resultado

# La llama el heroe cuando eligen la ofuda en el menu de mejoras
func subir_nivel() -> void:
	nivel += 1
	cantidad += 1
	dano += 2
