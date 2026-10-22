extends Yokai
# Cuervo tengu: rapido, con poca vida, llega volando en curva.
var giro := 0.0

func _ready() -> void:
	super() # corre el ready del molde (grupo "enemigos" y buscar al heroe)
	add_to_group("cuervos")
	giro = randf_range(-1.2, 1.2) # cada cuervo sale con una curva distinta

func mover(delta: float) -> void:
	var dir := global_position.direction_to(heroe.global_position).rotated(giro)
	giro = move_toward(giro, 0.0, 0.8 * delta) # la curva se va enderezando
	velocity = dir * velocidad
	move_and_slide()
