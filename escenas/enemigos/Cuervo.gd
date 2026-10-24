extends Yokai
# Cuervo tengu: rapido, con poca vida, llega volando en curva.
var giro := 0.0

func _ready() -> void:
	super() # corre el ready del molde (grupo "enemigos" y buscar al heroe)
	add_to_group("cuervos")
	giro = randf_range(-1.2, 1.2) # cada cuervo sale con una curva distinta
	poner_dibujo()

func mover(delta: float) -> void:
	var dir := global_position.direction_to(heroe.global_position).rotated(giro)
	giro = move_toward(giro, 0.0, 0.8 * delta) # la curva se va enderezando
	velocity = dir * velocidad
	move_and_slide()

# Si existe arte/yokais/cuervo.png (2 cuadros de 16x16), lo usa en vez del cuadro.
# Se llama "Sprite" para que el molde Yokai lo anime y lo voltee solo.
func poner_dibujo() -> void:
	var ruta := "res://arte/yokais/cuervo.png"
	if not ResourceLoader.exists(ruta) or has_node("Sprite"):
		return
	var dibujo := Sprite2D.new()
	dibujo.name = "Sprite"
	dibujo.texture = load(ruta)
	dibujo.hframes = 2
	add_child(dibujo)
	$ColorRect.visible = false
