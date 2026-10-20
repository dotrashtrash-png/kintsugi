extends CanvasLayer

# El HUD es lo que se ve encima del juego: barra de experiencia, vida, reloj, nivel y botín.
# No guarda nada: cada cuadro lee los números del Run (su nodo padre) y los muestra.

@onready var run = get_parent()


func _process(_delta: float) -> void:
	var restante := maxf(0.0, run.duracion - run.tiempo)
	var minutos := int(restante / 60.0)
	var segundos := int(restante) % 60
	if run.jefe_aparecio:
		$LabelTiempo.text = "¡El Gran Tengu!"
	else:
		$LabelTiempo.text = "%d:%02d" % [minutos, segundos]
	$LabelVida.text = "Vida %d / %d" % [run.heroe.vida, run.heroe.vida_maxima]
	$LabelNivel.text = "Nivel %d" % run.nivel
	$BarraXP.max_value = run.experiencia_necesaria
	$BarraXP.value = run.experiencia
	var m: Dictionary = run.recolectado
	$LabelMateriales.text = "Madera %d · Tejas %d · Oro %d · Aldeanos %d" % [m["madera"], m["tejas"], m["oro"], run.aldeanos_rescatados]
