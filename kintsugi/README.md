# Kintsugi

Juego 2D en Godot con yokais japoneses. Sales de la aldea a recoger materiales (*runs*), vuelves, reparas edificios y desbloqueas héroes hasta despertar a Kohaku.

## Cómo abrirlo

1. Instala **Godot 4.7** (render GL Compatibility).
2. Clona el repo y abre `project.godot` desde el gestor de proyectos de Godot.
3. Dale a Play (F5). La escena principal es el menú principal.

Controles: `WASD` o flechas para moverte.

## Estructura

| Carpeta | Contenido |
|---|---|
| `arte/` | Sprites. PNG 16x16, nombres en minúscula, sin tildes ni espacios, animaciones en tira horizontal. Una subcarpeta por categoría (`heroes`, `yokais`, `aldea`, `tiles`, `ui`, `intro`). |
| `audio/` | Música y efectos (`sfx/`). |
| `datos/` | Datos del juego: `edificios.gd`, `heroes.gd`. |
| `escenas/base/` | La aldea y sus edificios. |
| `escenas/run/` | Las salidas de combate: HUD, luz, materiales, menú de mejoras. |
| `escenas/enemigos/` | Yokais, spawner y rescate. |
| `escenas/jugador/` | Héroe, armas y proyectiles. |
| `escenas/efectos/` | Efectos visuales. |
| `escenas/ui/` | Menú principal y diálogos. |
| `escenas/pruebas/<persona>/` | Escenas de prueba personales. **No van al juego final.** |
| `scripts/autoload/` | `Estado` (progreso y materiales) y `Audio`. |

## Cómo se trabajó en la jam

- Todo se sube directo a `main`. Antes de empezar y antes de subir: **Pull**.
- Si el Pull dice *"untracked working tree files would be overwritten"*: cerrar Godot, descartar los `.import` del error y repetir el Pull.
- Las escenas de prueba van en `escenas/pruebas/<persona>/` y no se exportan.
- Los nombres de archivo distinguen mayúsculas en la versión Web: escenas en PascalCase, scripts y carpetas en minúscula.

## Equipo

Miguel Ángel Cano (líder y código) · Juan José Marín (código y arte) · Juan Sebastián Cadavid (código) · Juan Guillermo Miller (código) · Juan José Villa (código) · Luis Miguel Matta (arte)

Hecho para la **Cali Game Jam #4 · Edición Colombia Solidaria** (tema: *Reconstruir*).
