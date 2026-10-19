extends Node

signal cambio

var materiales := {"madera": 0, "tejas": 0, "oro": 0}
var aldeanos := 0
var edificios: Array[String] = []
var heroes_desbloqueados: Array[String] = ["ronin"]
var heroe_elegido := "ronin"
