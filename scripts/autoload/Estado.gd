extends Node

signal cambio

var materiales := {"madera": 0, "tejas": 0, "oro": 0}
var aldeanos := 0
var edificios: Array[String] = []
var heroes_desbloqueados: Array[String] = ["ronin"]
var heroe_elegido := "ronin"
var ultima_salida := {}

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
	ultima_salida = {"botin": botin, "aldeanos": aldeanos_rescatados, "sobrevivio": sobrevivio}
	cambio.emit()

func esta_reparado(id: String) -> bool:
	return edificios.has(id)

func puede_reparar(id: String) -> bool:
	var datos: Dictionary = Edificios.LISTA[id]
	if esta_reparado(id):
		return false
	if aldeanos < datos["aldeanos"]:
		return false
	return puede_pagar(datos["costo"])

func reparar(id: String) -> bool:
	if not puede_reparar(id):
		return false
	pagar(Edificios.LISTA[id]["costo"])
	edificios.append(id)
	aplicar_efecto(id)
	cambio.emit()
	return true

func aplicar_efecto(id: String) -> void:
	match id:
		"torii":
			desbloquear_heroe("miko")
		"biblioteca":
			desbloquear_heroe("onmyoji")

func desbloquear_heroe(id: String) -> void:
	if not heroes_desbloqueados.has(id):
		heroes_desbloqueados.append(id)

func bono_vida() -> float:
	return 0.2 if esta_reparado("onsen") else 0.0
