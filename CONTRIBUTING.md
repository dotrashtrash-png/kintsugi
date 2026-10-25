# Cómo contribuir

## Flujo

1. Trabaja siempre en **tu rama** (`miller`, `juancadavid`, `juanmarin`, `villa`, `lopez` o `miguel`). Si aún no existe, créala desde `main`: `git checkout main && git pull && git checkout -b tu-nombre`.
2. Antes de empezar cada día, trae lo nuevo: `git pull origin main` desde tu rama.
3. Haz commits pequeños y empuja tu rama.
4. Abre un pull request de tu rama hacia `main`. Abre el proyecto en Godot antes para comprobar que corre.
5. Lopez revisa y mezcla (en las revisiones: arte con nombre en la lista, PNG transparente, tamaño exacto y en `arte/<carpeta>/`).
6. Si tienes cambios a medias y vas a cambiar de rama, súbelos antes.

No hagas push directo a `main` ni force push.

## Commits

Mensaje corto, en español, que diga **qué** cambia. Ejemplos:

- `Agrega el Tengu y su spawner`
- `Corrige el costo de reparar el torii`

Evita mensajes como `asdasd` o `cambios`.

## Reglas de Godot para no pisarnos

- **Una persona por escena** a la vez. Los `.tscn` se resuelven muy mal en un conflicto de merge. Avisa en el grupo antes de tocar una escena ajena.
- **Sube siempre los `.uid` y los `.import`**. Si no, Godot los regenera distinto en cada máquina.
- Nunca subas la carpeta `.godot/`.
- Mueve y renombra archivos **desde el editor de Godot**, no desde el explorador, para que se actualicen las referencias.
- Tus escenas de prueba van en `escenas/pruebas/<tu-nombre>/`.
- Arte: PNG 16x16, nombres en minúscula, sin tildes ni espacios.
