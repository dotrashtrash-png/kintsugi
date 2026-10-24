extends Node2D

signal elegido(id: String)

@export var id := "onsen"

const COLOR_RUINA := Color(0.45, 0.45, 0.5) 
const RUTA_DIBUJO := "res://arte/aldea/%s.png"
const RUTA_VETAS := "res://arte/aldea/vetas_oro.png"

var escala_base := Vector2.ONE

func _ready() -> void:
	escala_base = scale
	$Boton.pressed.connect(_on_boton_pressed)
	var ruta := RUTA_DIBUJO % id
	if ResourceLoader.exists(ruta):
		$Dibujo.texture = load(ruta)
		$Cuadro.visible = false
	if ResourceLoader.exists(RUTA_VETAS):
		$Vetas.texture = vetas_recortadas()
	actualizar()

func actualizar() -> void:
	var datos: Dictionary = Edificios.LISTA[id]
	var reparado := Estado.esta_reparado(id)
	$Dibujo.modulate = Color.WHITE if reparado else COLOR_RUINA
	$Vetas.visible = reparado
	$Cuadro.color = Color(1.0, 0.8, 0.35) if reparado else Color(0.4, 0.4, 0.45)
	if reparado:
		$Nombre.text = datos["nombre"]
		$Nombre.modulate = Color.WHITE
	else:
		$Nombre.text = datos["nombre"] + "\n" + texto_costo()
		$Nombre.modulate = Color(1, 0.85, 0.4) if Estado.puede_reparar(id) else Color.WHITE

func texto_costo() -> String:
	var datos: Dictionary = Edificios.LISTA[id]
	var partes := PackedStringArray()
	for tipo in datos["costo"]:
		partes.append("%d %s" % [datos["costo"][tipo], tipo])
	if datos["aldeanos"] > 0:
		partes.append("%d aldeanos" % datos["aldeanos"])
	return ", ".join(partes)

# Las vetas de oro son las mismas para los 5 edificios. Aqui se borran las partes
# que caen fuera del dibujo, para que no queden lineas doradas flotando en el aire.
func vetas_recortadas() -> Texture2D:
	var original: Texture2D = load(RUTA_VETAS)
	if $Dibujo.texture == null:
		return original
	var vetas: Image = original.get_image()
	var dibujo: Image = $Dibujo.texture.get_image()
	if vetas.get_size() != dibujo.get_size():
		return original
	if vetas.is_compressed():
		vetas.decompress()
	if dibujo.is_compressed():
		dibujo.decompress()
	vetas.convert(Image.FORMAT_RGBA8)
	for y in vetas.get_height():
		for x in vetas.get_width():
			if dibujo.get_pixel(x, y).a < 0.5:
				vetas.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(vetas)

func celebrar() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", escala_base * 1.15, 0.12)
	t.tween_property(self, "scale", escala_base, 0.25)
	$Vetas.modulate = Color(2.5, 2.2, 1.2)
	create_tween().tween_property($Vetas, "modulate", Color.WHITE, 0.8)

func _on_boton_pressed() -> void:
	elegido.emit(id)
