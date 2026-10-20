extends CanvasLayer

# Menú que sale al subir de nivel: pausa el juego y muestra hasta 3 mejoras.
# Truco: este nodo tiene Process > Mode = "When Paused", así que es lo único
# que sigue funcionando mientras todo lo demás está congelado.

signal mejora_elegida(nombre: String)

var opciones: Array = []
@onready var botones := [$Panel/VBox/Boton1, $Panel/VBox/Boton2, $Panel/VBox/Boton3]


func _ready() -> void:
	visible = false
	for i in botones.size():
		# bind(i) hace que cada botón diga cuál es: 0, 1 o 2.
		botones[i].pressed.connect(_on_boton.bind(i))


# El Run llama esto con 1 a 3 nombres, por ejemplo ["katana", "waraji", "omamori"].
func mostrar(nuevas_opciones: Array) -> void:
	opciones = nuevas_opciones
	for i in botones.size():
		if i >= opciones.size():
			botones[i].visible = false
			continue
		botones[i].text = texto_de(opciones[i])
		botones[i].visible = true
	visible = true
	get_tree().paused = true
	botones[0].grab_focus() # también se elige con flechas y Enter


# Hoy Heroes.MEJORAS es solo una lista de nombres. Si Miguel la cambia por un
# diccionario con "nombre" y "texto", el menú los usa solo.
func texto_de(nombre: String) -> String:
	var lista = Heroes.MEJORAS # sin tipo a propósito (puede ser lista o diccionario)
	if lista is Dictionary and lista.has(nombre):
		var datos: Dictionary = lista[nombre]
		return "%s\n%s" % [datos.get("nombre", nombre), datos.get("texto", "")]
	return nombre.capitalize()


func _on_boton(indice: int) -> void:
	visible = false
	get_tree().paused = false
	Audio.sfx("boton")
	mejora_elegida.emit(opciones[indice])
