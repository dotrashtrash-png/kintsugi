extends Node
# Idioma del juego: español (el de siempre) o inglés.
# Los textos se siguen escribiendo en español; el inglés está en datos/traducciones.gd.
# Labels y botones se traducen solos. Solo los textos armados con números
# necesitan tr() en el script:   $LabelNivel.text = tr("Nivel %d") % nivel
#
# Uso:  Idioma.cambiar()   -> pasa de español a inglés y al revés (y lo guarda)
#       Idioma.actual      -> "es" o "en"

signal cambio

const ARCHIVO := "user://idioma.cfg" # aparte de la partida: "Borrar partida" no lo toca
const IDIOMAS := ["es", "en"]

var actual := "es" # el juego arranca en español


func _ready() -> void:
	var ingles := Translation.new()
	ingles.locale = "en"
	# El español también se registra (cada texto apunta a sí mismo). Sin esto, Godot
	# usa el inglés como respaldo y saldría en inglés aunque elijas español.
	var espanol := Translation.new()
	espanol.locale = "es"
	for texto: String in Traducciones.EN:
		ingles.add_message(texto, Traducciones.EN[texto])
		espanol.add_message(texto, texto)
	TranslationServer.add_translation(ingles)
	TranslationServer.add_translation(espanol)

	var cfg := ConfigFile.new()
	if cfg.load(ARCHIVO) == OK:
		actual = str(cfg.get_value("idioma", "actual", "es"))
	if not actual in IDIOMAS:
		actual = "es"
	TranslationServer.set_locale(actual)


func poner(codigo: String) -> void:
	if not codigo in IDIOMAS:
		return
	actual = codigo
	TranslationServer.set_locale(codigo)
	var cfg := ConfigFile.new()
	cfg.set_value("idioma", "actual", codigo)
	cfg.save(ARCHIVO)
	cambio.emit()


func cambiar() -> void:
	poner("en" if actual == "es" else "es")
