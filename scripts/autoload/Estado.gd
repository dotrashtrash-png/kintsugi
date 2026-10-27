extends Node

signal cambio

const ARCHIVO := "user://kintsugi.cfg"

var materiales := {"madera": 0, "tejas": 0, "oro": 0}
var aldeanos := 0
var edificios: Array[String] = []
var heroes_desbloqueados: Array[String] = ["ronin"]
var heroe_elegido := "ronin"
var ultima_salida := {} 
var vio_intro := false
var vio_tutorial := false # el tutorial del menu sale una sola vez
var salidas := 0 

func _ready() -> void:
	cargar()

# Tecla pegada: si sueltas la tecla cuando el juego no tiene el foco (clic afuera, cambiar
# de pestaña o de ventana, la barra de itch), el navegador nunca avisa que la soltaste y el
# heroe sigue caminando solo. Al perder o recuperar el foco se sueltan todas.
func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_FOCUS_IN,
			NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_IN,
			NOTIFICATION_APPLICATION_PAUSED]:
		soltar_teclas()

func soltar_teclas() -> void:
	for accion in ["izquierda", "derecha", "arriba", "abajo", "ui_left", "ui_right", "ui_up", "ui_down"]:
		Input.action_release(accion)

func agregar(tipo: String, cantidad: int) -> void:
	materiales[tipo] += cantidad
	cambio.emit()

func puede_pagar(costo: Dictionary) -> bool:
	for tipo in costo:
		if materiales[tipo] < costo[tipo]:
			return false
	return true

func pagar(costo: Dictionary) -> bool:
	if not puede_pagar(costo):
		return false
	for tipo in costo:
		materiales[tipo] -= costo[tipo]
	cambio.emit()
	return true

func recibir_botin(botin: Dictionary, aldeanos_rescatados: int, sobrevivio: bool) -> void:
	for tipo in botin:
		materiales[tipo] += botin[tipo]
	aldeanos += aldeanos_rescatados
	salidas += 1
	ultima_salida = {"botin": botin, "aldeanos": aldeanos_rescatados, "sobrevivio": sobrevivio}
	guardar()
	cambio.emit()

func esta_reparado(id: String) -> bool:
	return edificios.has(id)

func puede_reparar(id: String) -> bool:
	var datos: Dictionary = Edificios.LISTA[id]
	if esta_reparado(id):
		return false
	if not faltan_requisitos(id).is_empty():
		return false
	if aldeanos < datos["aldeanos"]:
		return false
	return puede_pagar(datos["costo"])
	# Edificios que hay que reparar antes de este (vacio = ninguno)
func faltan_requisitos(id: String) -> Array:
	var faltan: Array = []
	for req in Edificios.LISTA[id].get("requiere", []):
		if not esta_reparado(req):
			faltan.append(req)
	return faltan

func reparar(id: String) -> bool:
	if not puede_reparar(id):
		return false
	pagar(Edificios.LISTA[id]["costo"])
	edificios.append(id)
	aplicar_efecto(id)
	guardar()
	cambio.emit()
	return true

func aplicar_efecto(id: String) -> void:
	match id:
		"torii":
			desbloquear_heroe("miko")
		"biblioteca":
			desbloquear_heroe("onmyoji")
		"puente":
			desbloquear_heroe("kunoichi")

func desbloquear_heroe(id: String) -> void:
	if id == "kunoichi" and not ResourceLoader.exists("res://escenas/jugador/Kunai.tscn"):
		return # sin kunai no hay kunoichi
	if not heroes_desbloqueados.has(id):
		heroes_desbloqueados.append(id)

func bono_vida() -> float:
	return 0.2 if esta_reparado("onsen") else 0.0

func tiene_partida() -> bool:
	return salidas > 0 or not edificios.is_empty()

func guardar() -> void:
	var archivo := ConfigFile.new()
	archivo.set_value("progreso", "materiales", materiales)
	archivo.set_value("progreso", "aldeanos", aldeanos)
	archivo.set_value("progreso", "edificios", edificios)
	archivo.set_value("progreso", "heroes", heroes_desbloqueados)
	archivo.set_value("progreso", "heroe_elegido", heroe_elegido)
	archivo.set_value("progreso", "vio_intro", vio_intro)
	archivo.set_value("progreso", "vio_tutorial", vio_tutorial)
	archivo.set_value("progreso", "salidas", salidas)
	archivo.save(ARCHIVO)

func cargar() -> void:
	var archivo := ConfigFile.new()
	if archivo.load(ARCHIVO) != OK:
		return 
	materiales = archivo.get_value("progreso", "materiales", materiales)
	aldeanos = archivo.get_value("progreso", "aldeanos", 0)
	edificios.assign(archivo.get_value("progreso", "edificios", []))
	heroes_desbloqueados.assign(archivo.get_value("progreso", "heroes", ["ronin"]))
	heroe_elegido = archivo.get_value("progreso", "heroe_elegido", "ronin")
	vio_intro = archivo.get_value("progreso", "vio_intro", false)
	vio_tutorial = archivo.get_value("progreso", "vio_tutorial", false)
	salidas = archivo.get_value("progreso", "salidas", 0)

func reiniciar() -> void:
	materiales = {"madera": 0, "tejas": 0, "oro": 0}
	aldeanos = 0
	edificios.clear()
	heroes_desbloqueados.assign(["ronin"])
	heroe_elegido = "ronin"
	ultima_salida = {}
	vio_intro = false
	vio_tutorial = false # quien borra la partida empieza de cero: lo vuelve a ver
	salidas = 0
	guardar()
	cambio.emit()
