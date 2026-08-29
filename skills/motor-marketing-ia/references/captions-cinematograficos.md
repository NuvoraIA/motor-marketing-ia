# Referencia — Captions cinematográficos (Remotion)

Sistema de diseño para subtítulos de nivel editorial en reels y videos: en vez de la
tira fija de subtítulos de siempre, las palabras clave se vuelven momentos visuales —
grandes, con vidrio translúcido, colocadas alrededor de la persona. Es la diferencia
entre "video con subtítulos" y "video que se ve de agencia".

> Sistema adaptado a Remotion desde el skill MIT `hyperframes-cinematic-caption`
> de audrey-560 (github.com/audrey-560/hyperframes-cinematic-caption).

## 1. Editar el discurso en "cues" (no subtitular todo)

- Cada cue muestra **2–5 palabras** durante ~0.65–1.8 s. Cortá por significado,
  contraste y respiración — no por conteo fijo.
- Eliminá muletillas. Mayúsculas/minúsculas naturales; TODO EN MAYÚSCULA solo para
  siglas, etiquetas de prueba cortas o UNA palabra de CTA deliberada.
- Asigná un rol a cada cue: `setup` (contexto), `anchor` (idea clave), `contrast`
  (reversa), `proof` (número/lugar/dato), `aside` (puente), `payoff` (conclusión),
  `cta` (acción pedida).
- Agrupá cues en unidades semánticas (una cláusula, una prueba, un CTA) con orden de
  lectura fijo — los fragmentos de una misma oración comparten zona y dirección.

## 2. Elegir las palabras "héroe" (con puntaje, no por gusto)

Tres niveles de énfasis en 1080×1920: **support** (52–80 px, blanco limpio),
**anchor** (76–112 px, semibold, un acento), **hero** (150–240 px, display extra-bold;
un número o lugar corto puede llegar a 280 px).

Distribución sana: 60–75% support, 20–35% anchor, **máximo 5–15% hero**.

Puntaje para promover a hero (umbral: 4+):
- +3 si quitar la palabra debilita el argumento
- +2 si es prueba concreta (número, lugar, resultado)
- +2 si lleva el énfasis hablado (reversa, remate, CTA)
- +1 si es corta y legible a escala gigante
- −3 muletilla o sustantivo genérico · −2 si un cue vecino ya enfatiza lo mismo
- −2 si no hay lugar seguro donde ponerla

Un pasaje puede no tener ninguna palabra hero — eso también es válido.

## 3. Colocación alrededor del sujeto

- Zona segura vertical 1080×1920: x 90–990, y 240–1520. Nunca sobre la franja de UI
  de la plataforma (abajo).
- Revisá inicio, mitad y fin de cada cue: dónde están cara, boca, pelo, hombros,
  manos y producto. **Nunca tapes cara, boca, gesto clave, producto o UI** (mínimo
  40 px de distancia de la cara).
- Posiciones válidas: superior-izq/der, hombro-izq/der, hueco central, inferior-izq/der.
- Cada grupo semántico elige UNA dirección de lectura (ej. arriba-izq → abajo-der) y
  no la invierte. La variedad viene al cambiar de grupo, no zigzagueando en la oración.
- En 8–12 s usá 3–5 estados de layout, cambiando solo 1–2 propiedades entre grupos.

## 4. Tratamientos visuales

- **Editorial limpio** (la mayoría): sans nítida, sin caja, sombra suave solo si hace falta.
- **Hero translúcido "vidrio"**: relleno al 32–55% de opacidad (el video se ve a través
  de las letras), borde fino de 0.75–1.25 px, brillo interno sutil con un barrido de luz
  de 0.4–0.8 s. Plateado-blanco por defecto; UN tono de acento solo si la marca lo pide.
  Nada de arcoíris pastel, neón permanente ni scan-lines.
- **Número/lugar a escala de prueba**: un precio, un %, una ciudad se tratan como
  evidencia visual — mucho más grandes que el texto normal, con etiqueta chica al lado.
- **Profundidad detrás del sujeto**: solo con un recorte/matte real del sujeto
  (3 capas: video base → palabra gigante → recorte del sujeto encima). Presupuesto de
  oclusión: 10–30% del glifo cruzando pelo/hombros; cara y boca jamás. **Si no hay
  matte limpio, NO finjas la profundidad** — colocá la palabra al lado en espacio libre.
- Tipografía real: pesos que existan en el archivo de la fuente (nunca bold sintético
  del navegador ni engrosar con stroke).

## 5. Motion (rápido y decidido: 0.18–0.45 s)

`support-cascade` (sube 10–22 px con stagger de 30–55 ms) · `firm-settle`
(escala 0.88→1.04→1 al aterrizar) · `editorial-wipe` (reveal con overflow oculto) ·
`bloom-settle` (brillo que entra y se asienta) · `fill-drift` (la letra queda quieta,
el relleno interno se mueve). Solo transform + opacity; determinístico y seek-safe.
En frases progresivas, cada palabra aparece en SU momento hablado — nunca mostrar el
lockup completo antes de tiempo.

## 6. Sonido (opcional, como puntuación)

Máximo un acento audible por beat de énfasis, pegado al aterrizaje visual: support =
silencio; anchor = pop apagado; hero = golpe grave corto; reveal luminoso = un solo
shimmer. Generá los SFX con ElevenLabs, mezclalos DEBAJO de la narración, y rotá el
carácter del sonido entre beats vecinos (no repetir el mismo chime).

## 7. Implementación en Remotion

- Plan primero: escribí `caption-plan.json` (cue, texto exacto, rol, énfasis, razón
  del hero, posición, tratamiento, motion, timing en segundos) antes de codear.
- Timing word-level: transcribí la locución (la misma que generaste con ElevenLabs —
  ya tenés el guion, así que alineá por palabra) y sincronizá cada cue con
  `useCurrentFrame()` + los tiempos del plan (segundos × fps).
- Cada cue = un `<Sequence from={inicio} durationInFrames={dur}>` con el texto
  posicionado absoluto; animá el wrapper interno con `interpolate`/`spring`.
- Vidrio translúcido: color con alpha (`rgba(255,255,255,0.45)`) + `WebkitTextStroke`
  fino + un gradiente animado con `backgroundClip: 'text'` para el barrido de luz.
- Detrás del sujeto: capa 1 `<OffthreadVideo>` base → capa 2 el texto hero → capa 3 el
  recorte del sujeto (video con alpha o `higgsfield` remove_background) por encima.
- Fuentes locales con `@remotion/google-fonts` o `staticFile()` — nada remoto en render.
- Verificá con capturas en inicio/mitad/fin de cada hero antes de renderizar.

## Checklist final
- [ ] Cada hero tiene razón anotada y puntaje 4+ (o no hay hero, y está bien)
- [ ] Nada tapa cara/boca/producto en TODO el rango del cue
- [ ] Support mayormente blanco, jerarquía clara, sin karaoke bottom-center
- [ ] Los builds progresivos siguen los word-starts reales
- [ ] Profundidad solo con matte real; ortografía del hero siempre legible
- [ ] Sonido: un acento por beat, narración siempre inteligible
