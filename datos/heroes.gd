class_name Heroes

# Cada heroe es solo datos.
# "sprite" es su hoja de 64x16 con 4 cuadros: abajo, arriba, izquierda, derecha.
# Si el archivo no existe, el heroe sale como cuadro azul y no pasa nada.
const LISTA := {
	"ronin": {"arma": "katana", "vida": 125, "velocidad": 110.0, "radio": 40.0, "sprite": "res://arte/heroes/ronin.png"},
	"miko": {"arma": "campana", "vida": 100, "velocidad": 110.0, "radio": 40.0, "regen": 1.0, "sprite": "res://arte/heroes/miko.png"},
	"onmyoji": {"arma": "ofuda", "vida": 90, "velocidad": 110.0, "radio": 52.0, "sprite": "res://arte/heroes/onmyoji.png"},
	"kunoichi": {"arma": "kunai", "vida": 85, "velocidad": 132.0, "radio": 40.0, "sprite": "res://arte/heroes/kunoichi.png"},
}

# Lo que sale en el menu de mejoras. Las claves son las que recibe heroe.mejorar().
# Si una clave es un arma, su escena es escenas/jugador/<Clave>.tscn (kunai -> Kunai.tscn).
# Si esa escena todavia no existe, el Run no la ofrece.
const MEJORAS := {
	"katana": {"nombre": "Katana", "texto": "Corte al frente. Más daño y alcance."},
	"campana": {"nombre": "Campana suzu", "texto": "Onda que purifica y empuja."},
	"ofuda": {"nombre": "Ofuda", "texto": "Talismanes que persiguen yokais."},
	"kunai": {"nombre": "Kunai", "texto": "Cuchillos en línea que atraviesan."},
	"kitsunebi": {"nombre": "Kitsunebi", "texto": "Fuegos de zorro que giran a tu alrededor."},
	"waraji": {"nombre": "Waraji", "texto": "+10 % de velocidad."},
	"haori": {"nombre": "Haori", "texto": "+20 de vida máxima."},
	"omamori": {"nombre": "Omamori", "texto": "+20 % de radio para recoger."},
	"hachimaki": {"nombre": "Hachimaki", "texto": "+15 % de daño de todas las armas."},
}
