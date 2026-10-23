extends Node

func _ready() -> void:
	Estado.reiniciar()
	Estado.recibir_botin({"madera": 20, "tejas": 10, "oro": 0}, 1, true)
	Estado.reparar("onsen")
	print("Guardado: ", Estado.materiales, " edificios ", Estado.edificios)
	Estado.materiales = {"madera": 0, "tejas": 0, "oro": 0}
	Estado.edificios.clear()
	Estado.cargar()
	print("Cargado: ", Estado.materiales, " edificios ", Estado.edificios)
	print("Tiene partida: ", Estado.tiene_partida()) 
	Estado.reiniciar()
	print("Despues de reiniciar: ", Estado.tiene_partida()) 
