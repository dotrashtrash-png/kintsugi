extends Node

func _ready() -> void:
	print("Inicio: ", Estado.materiales)
	Estado.recibir_botin({"madera": 12, "tejas": 6, "oro": 0}, 1, true)
	print("Despues: ", Estado.materiales, " aldeanos: ", Estado.aldeanos)
	print("Puedo reparar onsen? ", Estado.puede_reparar("onsen")) # true
	print("Reparar onsen: ", Estado.reparar("onsen")) # true
	print("Quedan: ", Estado.materiales, " bono: ", Estado.bono_vida())
	print("Puedo reparar torii? ", Estado.puede_reparar("torii")) # false
