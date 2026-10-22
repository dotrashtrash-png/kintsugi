extends Yokai

# Nurikabe: muro vivo. Lento, con mucha vida, empuja al heroe y suelta oro.
@export var fuerza_empuje := 220.0

func revisar_contacto(delta: float) -> void:
	espera_dano -= delta
	if espera_dano > 0.0:
		return
	if global_position.distance_to(heroe.global_position) < distancia_contacto:
		heroe.recibir_dano(dano)
		heroe.empujar(global_position.direction_to(heroe.global_position) * fuerza_empuje)
		espera_dano = PAUSA_DANO

func elegir_material() -> String:
	return "oro"
