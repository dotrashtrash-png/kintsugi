class_name Heroes

const LISTA := {
	"ronin": {"arma": "katana", "vida": 125, "velocidad": 110.0, "radio": 40.0},
	"miko": {"arma": "campana", "vida": 100, "velocidad": 110.0, "radio": 40.0, "regen": 1.0},
	"onmyoji": {"arma": "ofuda", "vida": 90, "velocidad": 110.0, "radio": 52.0},
}

# Lo que sale en el menu de mejoras. Las claves son las que recibe heroe.mejorar().
const MEJORAS := {
	"katana": {"nombre": "Katana", "texto": "Corte al frente. Más daño y alcance."},
	"campana": {"nombre": "Campana suzu", "texto": "Onda que purifica y empuja."},
	"ofuda": {"nombre": "Ofuda", "texto": "Talismanes que persiguen yokais."},
	"waraji": {"nombre": "Waraji", "texto": "+10 % de velocidad."},
	"haori": {"nombre": "Haori", "texto": "+20 de vida máxima."},
	"omamori": {"nombre": "Omamori", "texto": "+20 % de radio para recoger."},
}
