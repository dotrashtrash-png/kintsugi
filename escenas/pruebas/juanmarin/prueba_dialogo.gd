extends Node2D

# Prueba de la caja de diálogo: F6 en PruebaDialogo.tscn.
# Sale la abuela Haru; clic o Enter la cierra; después sale una segunda frase.

func _ready() -> void:
	$Dialogo.cerrado.connect(_on_cerrado)
	$Dialogo.mostrar("Hola, soy la abuela Haru. Las grietas no se esconden, hijo: se llenan de oro.")

var veces := 0

func _on_cerrado() -> void:
	veces += 1
	print("Diálogo cerrado (", veces, ")")
	if veces == 1:
		$Dialogo.mostrar("Así se ve una frase de otro personaje.", "Kohaku")
