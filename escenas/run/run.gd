extends Node2D

# El Run es la partida: guarda lo que pasa (experiencia, nivel, botin, tiempo)
# y junta las piezas de los demas (Heroe, Spawner, Zona, Tengu).

@export var duracion := 360.0 # 6 minutos

const RUTA_TENGU := "res://escenas/enemigos/Tengu.tscn"
const RUTA_ALDEA := "res://escenas/base/Aldea.tscn"
const RUTA_PAUSA := "res://escenas/run/Pausa.tscn"
const CONTROLES_TACTILES := preload("res://escenas/run/controles_tactiles.gd")
const MEJORAS_QUE_NO_SON_ARMAS := ["waraji", "haori", "omamori", "hachimaki"]
const NIVEL_MAXIMO := 8 # el mismo numero que en heroe.gd
const MARGEN_BORDE := 10.0 # el heroe no se acerca mas que esto al borde del mapa

var tiempo := 0.0
var experiencia := 0
var nivel := 1
var experiencia_necesaria := 5
var niveles_pendientes := 0
var recolectado := {"madera": 0, "tejas": 0, "oro": 0}
var aldeanos_rescatados := 0
var jefe_aparecio := false
var terminado := false
var limites := Rect2() # el rectangulo del mapa en pixeles (vacio si no hay Zona)

@onready var heroe = $Heroe


func _ready() -> void:
	add_to_group("run")
	Yokai.humos_vivos = 0 # contadores de efectos: empiezan limpios en cada salida
	Estado.soltar_teclas()
	heroe.murio.connect(_on_heroe_murio)
	if has_node("MenuMejoras"):
		$MenuMejoras.mejora_elegida.connect(_on_mejora_elegida)
	calcular_limites()
	if ResourceLoader.exists(RUTA_PAUSA):
		add_child(load(RUTA_PAUSA).instantiate())
	# En celular: joystick donde pongas el dedo y boton de pausa
	if DisplayServer.is_touchscreen_available():
		var tactil := CanvasLayer.new()
		tactil.set_script(CONTROLES_TACTILES)
		add_child(tactil)
	Audio.musica("run")


# Mide el mapa (la imagen Fondo de la Zona) y le pone esos bordes a la camara del heroe.
func calcular_limites() -> void:
	if has_node("Zona/Fondo"):
		var fondo: Sprite2D = $Zona/Fondo
		var r: Rect2 = fondo.get_rect()
		limites = Rect2(fondo.to_global(r.position), r.size * fondo.global_scale)
	elif has_node("Zona/Suelo"):
		var suelo: TileMapLayer = $Zona/Suelo
		var celdas: Rect2i = suelo.get_used_rect()
		var tam := Vector2(suelo.tile_set.tile_size)
		var esquina: Vector2 = suelo.to_global(Vector2(celdas.position) * tam)
		limites = Rect2(esquina, Vector2(celdas.size) * tam)
	else:
		return
	var camara: Camera2D = heroe.get_node("Camera2D")
	camara.limit_left = int(limites.position.x)
	camara.limit_top = int(limites.position.y)
	camara.limit_right = int(limites.end.x)
	camara.limit_bottom = int(limites.end.y)


func _process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	if tiempo >= duracion and not jefe_aparecio:
		aparecer_jefe()


# El heroe no puede pasar del borde del mapa
func _physics_process(_delta: float) -> void:
	if limites.has_area():
		var m := Vector2(MARGEN_BORDE, MARGEN_BORDE)
		heroe.global_position = heroe.global_position.clamp(limites.position + m, limites.end - m)


# ---------- Lo que llaman las demas piezas (contrato: no cambiar los nombres) ----------

func agregar_experiencia(cantidad: int) -> void:
	experiencia += cantidad
	while experiencia >= experiencia_necesaria:
		experiencia -= experiencia_necesaria
		nivel += 1
		experiencia_necesaria = 6 + nivel * 5 # cada nivel pide mas
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
		_on_mejora_elegida(opciones[0])


# Mejoras que se pueden ofrecer: las que existen y no han llegado al nivel maximo.
func mejoras_posibles() -> Array:
	var posibles: Array = []
	for nombre in Heroes.MEJORAS.keys():
		var existe: bool = heroe.ruta_arma(String(nombre)) != ""
		if not (nombre in MEJORAS_QUE_NO_SON_ARMAS or existe):
			continue # el arma todavia no existe
		if heroe.has_method("nivel_de") and heroe.nivel_de(nombre) >= NIVEL_MAXIMO:
			continue # ya esta al maximo
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
	# El Gran Tengu solo baja si el puente rojo esta reparado.
	# Antes de eso, sobrevivir los 6 minutos es ganar.
	if not Estado.esta_reparado("puente") or not ResourceLoader.exists(RUTA_TENGU):
		terminar(true)
		return
	var tengu = load(RUTA_TENGU).instantiate()
	add_child(tengu)
	var lugar: Vector2 = heroe.global_position + Vector2(200, 0)
	if limites.has_area():
		lugar = lugar.clamp(limites.position, limites.end)
	tengu.global_position = lugar
	tengu.vencido.connect(_on_tengu_vencido)
	Audio.musica("jefe") # si no existe mus_jefe, sigue la musica del run


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
	Audio.jingle("victoria" if sobrevivio else "derrota")
	# Aviso de 2 segundos antes de volver, para que se entienda que paso
	if has_node("HUD/LabelTiempo"):
		$HUD/LabelTiempo.text = "¡Sobreviviste!" if sobrevivio else "Caíste..."
	get_tree().paused = true
	await get_tree().create_timer(2.0, true).timeout # cuenta aunque el juego este en pausa
	get_tree().paused = false # nunca cambiar de escena en pausa
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
