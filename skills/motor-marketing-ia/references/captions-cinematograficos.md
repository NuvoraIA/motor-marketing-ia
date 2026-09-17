# Referencia — Captions cinematográficos

En vez de la tira fija de subtítulos de siempre, las palabras clave se vuelven momentos
visuales: grandes, con vidrio translúcido, colocadas alrededor de la persona. Es la
diferencia entre "video con subtítulos" y "video que se ve de agencia".

## Cómo se hace: usá el skill, no lo reimplementes

**Usá el skill `cinematic-caption`** — viene instalado con el Motor y corre dentro de
un proyecto HyperFrames ya armado. Primero terminá el video (ver
`references/hyperframes.md`), después aplicale los captions con ese skill. No escribas
un sistema de subtítulos a mano: el skill ya trae el scoring, los tratamientos y las
recetas de layout.

## La esencia (para que sepas qué estás pidiendo)

- **Cues, no transcripción:** 2–5 palabras por cue, cortadas por significado, no por
  conteo fijo. Sin muletillas.
- **Tres niveles de jerarquía:** `support` (blanco limpio, el 60–75%), `anchor` (idea
  clave, semibold con un acento) y `hero` (gigante, **máximo 5–15%** de los cues).
- **Las palabras hero se eligen con puntaje, no por gusto:** suma si quitarla debilita
  el argumento, si es prueba concreta (un número, un lugar, un resultado), si lleva el
  énfasis hablado y si es corta; resta si es muletilla, si el cue vecino ya enfatiza lo
  mismo o si no hay lugar seguro donde ponerla. Un pasaje puede no tener ninguna hero.
- **Vidrio translúcido** en las hero: relleno al 32–55% de opacidad (el video se ve a
  través de las letras), borde fino y un barrido de luz corto. Nada de neón ni arcoíris.
- **Posicionamiento consciente del sujeto:** nunca tapar cara, boca, gesto clave,
  producto ni la franja de UI de la plataforma, en **todo** el rango del cue. La
  profundidad detrás del sujeto solo con un recorte real; si no hay recorte limpio, la
  palabra va al lado, en espacio libre.
- **Motion rápido y decidido** (0.18–0.45 s), solo transform y opacity, determinístico
  y seek-safe. Cada palabra aparece en SU momento hablado.

> Sistema del skill MIT `hyperframes-cinematic-caption` de audrey-560
> (github.com/audrey-560/hyperframes-cinematic-caption), instalado como
> `cinematic-caption`.
