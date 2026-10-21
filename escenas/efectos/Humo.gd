extends CPUParticles2D

# El molde Yokai de Miller la crea donde muere cada yokai. Se borra sola.
func _ready() -> void:
	emitting = true
	$Papel.emitting = true
	# Espera 1 segundo y se borra, para que no se acumulen.
	var t := create_tween()
	t.tween_interval(1.0)
	t.tween_callback(queue_free)
