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

## Ramas

- `main`: siempre abre y corre. Solo entra por pull request.
- `dev`: integración. Aquí se juntan las ramas de trabajo antes de pasar a `main`.
- `feature/<tema>` o `fix/<tema>`: una por tarea, creada desde `dev`. Ejemplo: `feature/tengu`.

Mira [CONTRIBUTING.md](CONTRIBUTING.md) para el flujo completo.

## Ramas antiguas

- `origin/miller` (aparece en algunas vistas como `origin/origin/miller`): rama heredada con trabajo que aún no está en `main`. **Se va a eliminar.** Si algo de ahí sirve, pásalo a `dev` antes.
