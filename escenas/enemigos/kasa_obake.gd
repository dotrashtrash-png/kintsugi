extends Yokai

# Avanza a saltos: corre un rato, se queda quieta, corre otra vez.
@export var tiempo_salto := 0.35
@export var tiempo_quieto := 0.45
var reloj := 0.0
var saltando := false

# Reemplaza el mover() del molde base de los Yokais.
func mover(delta: float) -> void:
	reloj -= delta
	if reloj <= 0.0:
		saltando = not saltando
		reloj = tiempo_salto if saltando else tiempo_quieto
	
	if saltando:
		velocity = global_position.direction_to(objetivo()) * velocidad * ritmo
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
