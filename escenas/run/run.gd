extends Node2D

# El Run es la partida: guarda lo que pasa (experiencia, nivel, botín, tiempo)
# y junta las piezas de los demás (Heroe de Miguel, Spawner de Miller, Tengu de Villa).

@export var duracion := 360.0 # 6 minutos. Al llegar, aparece el Gran Tengu.

const RUTA_TENGU := "res://escenas/enemigos/Tengu.tscn"
const RUTA_ALDEA := "res://escenas/base/Aldea.tscn"
const MEJORAS_QUE_NO_SON_ARMAS := ["waraji", "haori", "omamori"]

var tiempo := 0.0
var experiencia := 0
var nivel := 1
var experiencia_necesaria := 5
var niveles_pendientes := 0
var recolectado := {"madera": 0, "tejas": 0, "oro": 0}
var aldeanos_rescatados := 0
var jefe_aparecio := false
var terminado := false

@onready var heroe = $Heroe


func _ready() -> void:
	# Así la Luz, el Material y el Rescate encuentran el Run.
	add_to_group("run")
	heroe.murio.connect(_on_heroe_murio)
	if has_node("MenuMejoras"):
		$MenuMejoras.mejora_elegida.connect(_on_mejora_elegida)
	Audio.musica("run")


func _process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	if tiempo >= duracion and not jefe_aparecio:
		aparecer_jefe()


# ---------- Lo que llaman las demás piezas (contrato: no cambiar los nombres) ----------

func agregar_experiencia(cantidad: int) -> void:
	experiencia += cantidad
	while experiencia >= experiencia_necesaria:
		experiencia -= experiencia_necesaria
		nivel += 1
		experiencia_necesaria = 5 + nivel * 3 # cada nivel pide un poco más
		niveles_pendientes += 1
	if niveles_pendientes > 0 and not get_tree().paused:
		mostrar_menu()


func agregar_material(tipo: String, cantidad: int) -> void:
	recolectado[tipo] += cantidad


func agregar_aldeano() -> void:
	aldeanos_rescatados += 1


# ---------- Subir de nivel ----------

func mostrar_menu() -> void:
	var opciones := mejoras_posibles()
	opciones.shuffle()
	opciones = opciones.slice(0, 3) # 3 al azar
	if opciones.is_empty():
		niveles_pendientes = 0
		return
	Audio.sfx("nivel")
	if has_node("MenuMejoras"):
		$MenuMejoras.mostrar(opciones)
	else:
		_on_mejora_elegida(opciones[0]) # todavía no hay menú: elige la primera


# Lista de mejoras que se pueden ofrecer, sacada de Heroes.MEJORAS (de Miguel).
# Salta las armas que todavía no existen (por ejemplo, si nadie ha subido Campana.tscn).
func mejoras_posibles() -> Array:
	# Hoy MEJORAS es una lista; la guía dice que Miguel la puede volver un diccionario.
	# "lista" va sin tipo a propósito, para que este código sirva en los dos casos.
	var lista = Heroes.MEJORAS
	var todas = []
	if lista is Dictionary:
		todas = lista.keys()
	else:
		todas = lista.duplicate() # copia: la original es const y no se puede mezclar
	var posibles: Array = []
	for nombre in todas:
		var ruta := "res://escenas/jugador/%s.tscn" % String(nombre).capitalize()
		if nombre in MEJORAS_QUE_NO_SON_ARMAS or ResourceLoader.exists(ruta):
			posibles.append(nombre)
	return posibles


func _on_mejora_elegida(nombre: String) -> void:
	heroe.mejorar(nombre)
	niveles_pendientes -= 1
	if niveles_pendientes > 0:
		mostrar_menu()


# ---------- Jefe y fin de la partida ----------

func aparecer_jefe() -> void:
	jefe_aparecio = true
	if not ResourceLoader.exists(RUTA_TENGU):
		terminar(true) # mientras Villa no lo suba, llegar al minuto 6 es ganar
		return
	var tengu = load(RUTA_TENGU).instantiate()
	add_child(tengu)
	tengu.global_position = heroe.global_position + Vector2(200, 0)
	tengu.vencido.connect(_on_tengu_vencido)


func _on_tengu_vencido() -> void:
	terminar(true)


func _on_heroe_murio() -> void:
	terminar(false)


func terminar(sobrevivio: bool) -> void:
	if terminado:
		return
	terminado = true
	var botin := recolectado.duplicate()
	if not sobrevivio:
		for tipo in botin:
			botin[tipo] = botin[tipo] / 2 # si cae, trae la mitad de los materiales
	Estado.recibir_botin(botin, aldeanos_rescatados, sobrevivio)
	get_tree().paused = false # ¡nunca cambiar de escena en pausa!
	get_tree().change_scene_to_file.call_deferred(RUTA_ALDEA)


# ---------- Teclas de prueba (solo en versiones de debug) ----------

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F2: tiempo = duracion - 3.0 # saltar al jefe
			KEY_F3: agregar_experiencia(experiencia_necesaria) # subir un nivel
			KEY_F4: terminar(true) # volver a la aldea ganando
