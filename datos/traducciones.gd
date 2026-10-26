class_name Traducciones

# Textos del juego en inglés. Los usa el autoload Idioma (scripts/autoload/Idioma.gd).
# Izquierda: el texto EXACTO en español, tal como está en el código o en la escena.
# Derecha: cómo se ve en inglés.
# - Si cambias un texto en español, cambia también su clave aquí (si no, en inglés sale en español).
# - Los %d, %s y %.1f tienen que quedar iguales y en el mismo orden a los dos lados.
# - Si armas un texto con números en tu script, pásalo por tr():  tr("Nivel %d") % nivel

const EN := {
	# ---------- Menú principal ----------
	"Repara la aldea con oro": "Mend the village with gold",
	"Jugar": "Play",
	"Cómo jugar": "How to play",
	"Créditos": "Credits",
	"Volver": "Back",
	"Sonido": "Sound",
	"Música": "Music",
	"Efectos": "Effects",
	"Listo": "Done",

	# ---------- Cómo jugar y créditos (textos largos: la clave es el texto completo) ----------
	"[b]Moverse:[/b] WASD o flechas\n[b]Atacar:[/b] tus armas atacan solas\n[b]Subir de nivel:[/b] recoge las luces doradas y elige una mejora\n[b]Rescatar aldeanos:[/b] quédate 3 segundos a su lado (¡cuidado, los yokais te rodean!)\n[b]Sobrevive 6 minutos[/b] y vuelves a la aldea con todo lo que juntaste. Si caes, traes la mitad.\n[b]En la aldea:[/b] repara edificios con madera, tejas y oro. Cada uno trae algo nuevo.\n[b]Esc o P:[/b] pausa": "[b]Move:[/b] WASD or arrow keys\n[b]Attack:[/b] your weapons attack on their own\n[b]Level up:[/b] pick up the golden lights and choose an upgrade\n[b]Rescue villagers:[/b] stay next to them for 3 seconds (careful, the yokai close in on you!)\n[b]Survive 6 minutes[/b] and you return to the village with everything you gathered. If you fall, you bring back half.\n[b]In the village:[/b] repair buildings with wood, tiles and gold. Each one brings something new.\n[b]Esc or P:[/b] pause",
	"KINTSUGI · Cali Game Jam #4, Edición Colombia Solidaria\n\nMiguel Angel Cano (do.trash) · Coordinación y código\nJuan Jose Marin (marin) · Código y arte\nJuan Sebastian Cadavid (juannn) · Código\nJuan Guillermo Miller (miller) · Código\nJuan Jose Villa (limon) · Código\nLuis Miguel Matta (m.r_cronos) · Arte\n\nArte base: Ninja Adventure de Pixel-boy (CC0)\nMúsica: Free Music : MOMIZizm MUSiC (music.storyinvention.com/en/)\nEfectos de sonido: creados para el juego\nFuente: DotGothic16 · Fontworks (SIL Open Font License)\nPortada, fondo del menú, piso de la aldea, retrato de Haru y Gran Tengu: generados con IA (Higgsfield)": "KINTSUGI · Cali Game Jam #4, Colombia Solidaria Edition\n\nMiguel Angel Cano (do.trash) · Coordination and code\nJuan Jose Marin (marin) · Code and art\nJuan Sebastian Cadavid (juannn) · Code\nJuan Guillermo Miller (miller) · Code\nJuan Jose Villa (limon) · Code\nLuis Miguel Matta (m.r_cronos) · Art\n\nBase art: Ninja Adventure by Pixel-boy (CC0)\nMusic: Free Music : MOMIZizm MUSiC (music.storyinvention.com/en/)\nSound effects: made for the game\nFont: DotGothic16 · Fontworks (SIL Open Font License)\nCover, menu background, village floor, Haru's portrait and Great Tengu: AI-generated (Higgsfield)",

	# ---------- Intro ----------
	"Clic o Enter para seguir · Esc para saltar": "Click or Enter to continue · Esc to skip",
	"Al pie de la montaña está Tsugimura. En la cima, el santuario de Kohaku, la zorra blanca de nueve colas que cuidaba la aldea.": "At the foot of the mountain lies Tsugimura. At the top, the shrine of Kohaku, the white nine-tailed fox who guarded the village.",
	"Con los años, la gente se fue ocupando en otras cosas. Nadie volvió a subir al santuario. Los faroles se apagaron, uno por uno.": "Over the years, people got busy with other things. No one climbed to the shrine anymore. The lanterns went out, one by one.",
	"La noche del Desfile de los Cien Demonios, nada detuvo a los yokais. Las casas quedaron en ruinas y los aldeanos se escondieron.": "On the night of the Parade of One Hundred Demons, nothing stopped the yokai. The houses fell to ruins and the villagers hid.",
	"La abuela Haru se quedó en su taller. Ella sabe reparar con oro. Pero alguien tiene que salir a buscar lo que se perdió.": "Grandma Haru stayed in her workshop. She knows how to repair with gold. But someone has to go out and find what was lost.",

	# ---------- Abuela Haru (datos/textos.gd) ----------
	"Abuela Haru": "Grandma Haru",
	"Bienvenido al taller. Las casas están rotas, no perdidas. Tráeme madera, tejas y oro, y las repararemos juntos.": "Welcome to the workshop. The houses are broken, not lost. Bring me wood, tiles and gold, and we'll repair them together.",
	"¡Rescataste a alguien! Cada persona que vuelve le devuelve fuerza a Kohaku.": "You rescued someone! Every person who comes home gives strength back to Kohaku.",
	"Si no sabes por dónde empezar: el onsen es lo más barato de reparar.": "If you don't know where to start: the onsen is the cheapest to repair.",
	"Todavía no alcanza. Sal otra vez: las ruinas guardan más de lo que parece.": "Not enough yet. Go out again: the ruins hold more than they seem.",
	"El agua caliente vuelve a correr. Saldrás con más fuerzas.": "The hot water flows again. You'll set out stronger.",
	"El torii brilla otra vez. La Miko, la sacerdotisa del santuario, quiere acompañarte.": "The torii shines again. The Miko, the shrine maiden, wants to come with you.",
	"Los pergaminos se salvaron. El Onmyōji ya puede leer sus talismanes.": "The scrolls were saved. The Onmyōji can now read his talismans.",
	"El puente rojo está en pie. La Kunoichi lo cruzó para ayudarte… y del otro lado baja el Gran Tengu. Ten cuidado.": "The red bridge stands again. The Kunoichi crossed it to help you… and from the other side, the Great Tengu is coming down. Be careful.",
	"El santuario está completo. Enciende los faroles. Kohaku está despertando.": "The shrine is whole again. Light the lanterns. Kohaku is waking up.",
	"Volviste entero. Con lo que trajiste ya podemos seguir.": "You came back in one piece. With what you brought, we can keep going.",
	"Qué alegría verte caminar de vuelta. Veamos qué rescataste.": "What a joy to see you walking back. Let's see what you saved.",
	"Las ruinas no pudieron contigo. Ven, trae eso aquí.": "The ruins couldn't beat you. Come, bring that over here.",
	"Caíste, pero volviste. Eso es lo que importa. Las grietas también se reparan.": "You fell, but you came back. That's what matters. Cracks can be mended too.",
	"Descansa un poco. Lo que trajiste igual sirve.": "Rest a little. What you brought still helps.",
	"Nadie vuelve intacto. Por eso existe el kintsugi.": "No one comes back unbroken. That's why kintsugi exists.",

	# ---------- Aldea ----------
	"Salir a las ruinas": "Head to the ruins",
	"Borrar partida": "Delete save",
	"+ materiales (prueba)": "+ materials (test)",
	"Madera %d · Tejas %d · Oro %d · Aldeanos %d": "Wood %d · Tiles %d · Gold %d · Villagers %d",
	"Madera": "Wood",
	"Tejas": "Tiles",
	"Oro": "Gold",
	"Aldeanos": "Villagers",
	"Toca un edificio en ruinas para repararlo.": "Click a ruined building to repair it.",
	"Volviste sano y salvo.": "You made it back safe and sound.",
	"Caíste, pero trajiste la mitad.": "You fell, but you brought back half.",
	"%s Trajiste %d madera, %d tejas, %d oro y %d aldeanos.": "%s You brought back %d wood, %d tiles, %d gold and %d villagers.",
	"%s ya está reparado.": "%s is already repaired.",
	"%s se repara al final: primero los otros edificios.": "%s is repaired last: fix the other buildings first.",
	"Te falta material o aldeanos para %s.": "Not enough materials or villagers for %s.",
	"¡Reparaste %s con oro!": "You repaired %s with gold!",
	"Primero repara los otros edificios": "Repair the others first",
	"Repara el torii": "Repair the torii",
	"Repara la biblioteca": "Repair the library",
	"Repara el puente": "Repair the bridge",
	"Bloqueado": "Locked",
	"Campana": "Bell",
	"¡Sobreviviste!": "You survived!",
	"Caíste…": "You fell…",
	"Trajiste la mitad": "You brought back half",
	"Clic o Enter para seguir": "Click or Enter to continue",

	# ---------- Edificios (datos/edificios.gd) ----------
	"Torii del santuario": "Shrine torii",
	"Biblioteca": "Library",
	"Puente rojo (abre el camino al Gran Tengu)": "Red bridge (opens the way to the Great Tengu)",
	"Santuario de Kohaku": "Kohaku's shrine",

	# ---------- Partida: HUD, jefe y rescates ----------
	"Vida": "HP",
	"Nivel 1": "Level 1",
	"Vida %d / %d": "HP %d / %d",
	"Nivel %d": "Level %d",
	"¡El Gran Tengu!": "The Great Tengu!",
	"Caíste...": "You fell...",
	"Gran Tengu": "Great Tengu",
	"Gran Tengu (furioso)": "Great Tengu (enraged)",
	"¡Rescatado! +%d oro": "Rescued! +%d gold",

	# ---------- Mejoras (datos/heroes.gd) ----------
	"¡Subiste de nivel! Elige una mejora": "Level up! Choose an upgrade",
	"%s (nueva)": "%s (new)",
	"%s Nv. %d → %d": "%s Lv. %d → %d",
	"Corte al frente. Más daño y alcance.": "Slash in front of you. More damage and reach.",
	"Campana suzu": "Suzu bell",
	"Onda que purifica y empuja.": "A purifying wave that pushes back.",
	"Talismanes que persiguen yokais.": "Talismans that chase down yokai.",
	"Cuchillos en línea que atraviesan.": "Knives in a line that pierce through.",
	"Fuegos de zorro que giran a tu alrededor.": "Fox fires that circle around you.",
	"+8 % de velocidad.": "+8% speed.",
	"+25 de vida máxima y cura 25.": "+25 max HP and heals 25.",
	"+25 % de radio para recoger.": "+25% pickup radius.",
	"+10 % de daño de todas las armas.": "+10% damage for all weapons.",

	# ---------- Pausa ----------
	"Pausa": "Paused",
	"Vida  %d / %d   (regenera %.1f por segundo)": "HP  %d / %d   (regenerates %.1f per second)",
	"Daño  x%.2f   ·   Velocidad  %d   ·   Radio para recoger  %d": "Damage  x%.2f   ·   Speed  %d   ·   Pickup radius  %d",
	"%s Nv. %d": "%s Lv. %d",
	"Armas:": "Weapons:",
	"Pasivas:": "Passives:",
	"ninguna": "none",
	"Esta salida:  Madera %d · Tejas %d · Oro %d · Aldeanos %d": "This run:  Wood %d · Tiles %d · Gold %d · Villagers %d",
	"Seguir  (Esc / P)": "Resume  (Esc / P)",
	"Volver a la aldea  (traes la mitad)": "Back to the village  (you keep half)",

	# ---------- Final ----------
	"Los faroles del santuario se encienden, uno por uno.": "The shrine's lanterns light up, one by one.",
	"Kohaku abre los ojos. Tsugimura recordó a su guardiana, y las grietas de la aldea brillan con oro.": "Kohaku opens her eyes. Tsugimura remembered its guardian, and the cracks in the village shine with gold.",
	"Lo que se rompe y se repara con cuidado puede ser más bello que antes.": "What breaks and is mended with care can be more beautiful than before.",
	"Gracias por jugar KINTSUGI.": "Thank you for playing KINTSUGI.",
}
