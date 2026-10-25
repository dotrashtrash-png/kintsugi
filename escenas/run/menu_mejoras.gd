extends CanvasLayer

# Menu que sale al subir de nivel: pausa el juego y muestra hasta 3 mejoras,
# cada una con su icono, su nivel y su texto.
# Process > Mode = "When Paused": es lo unico que funciona con el juego congelado.

signal mejora_elegida(nombre: String)

const RUTA_ICONO := "res://arte/ui/icono_%s.png"

var opciones: Array = []
@onready var botones := [$Panel/VBox/Boton1, $Panel/VBox/Boton2, $Panel/VBox/Boton3]


func _ready() -> void:
	visible = false
	for i in botones.size():
		botones[i].pressed.connect(_on_boton.bind(i))
		botones[i].expand_icon = true # el icono crece con el boton (se ve grande y nitido)
		botones[i].custom_minimum_size = Vector2(0, 52)
		botones[i].alignment = HORIZONTAL_ALIGNMENT_LEFT


# El Run llama esto con 1 a 3 claves, por ejemplo ["katana", "waraji", "kunai"].
func mostrar(nuevas_opciones: Array) -> void:
	opciones = nuevas_opciones
	var heroe = get_tree().get_first_node_in_group("jugador")
	for i in botones.size():
		if i >= opciones.size():
			botones[i].visible = false
			continue
		var nombre: String = opciones[i]
		botones[i].text = texto_de(nombre, heroe)
		var ruta := RUTA_ICONO % nombre
		botones[i].icon = load(ruta) if ResourceLoader.exists(ruta) else null
		botones[i].visible = true
	visible = true
	get_tree().paused = true
	botones[0].grab_focus() # tambien se elige con flechas y Enter


# "Kunai (nueva)" o "Katana Nv. 2 -> 3", y abajo el texto de la mejora
func texto_de(nombre: String, heroe) -> String:
	var datos: Dictionary = Heroes.MEJORAS.get(nombre, {})
	var titulo: String = tr(datos.get("nombre", nombre.capitalize()))
	var nivel_actual := 0
	if heroe and heroe.has_method("nivel_de"):
		nivel_actual = heroe.nivel_de(nombre)
	if nivel_actual == 0:
		titulo = tr("%s (nueva)") % titulo
	else:
		titulo = tr("%s Nv. %d → %d") % [titulo, nivel_actual, nivel_actual + 1]
	return titulo + "\n" + tr(str(datos.get("texto", "")))


func _on_boton(indice: int) -> void:
	visible = false
	get_tree().paused = false
	Audio.sfx("boton")
	mejora_elegida.emit(opciones[indice])
