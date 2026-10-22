# Cómo contribuir

## Flujo

1. Actualiza `dev`: `git checkout dev && git pull`.
2. Crea tu rama: `git checkout -b feature/<tema>` (o `fix/<tema>`).
3. Trabaja y haz commits pequeños.
4. Antes de empujar, trae lo nuevo de `dev` (`git pull origin dev`) y abre el proyecto en Godot para comprobar que corre.
5. Empuja y abre un pull request hacia `dev`.
6. Otra persona lo revisa y lo aprueba. No te apruebes tus propios PR.
7. Cuando `dev` esté estable, se hace un PR de `dev` a `main`.

No hagas push directo a `main` ni a `dev`.

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
