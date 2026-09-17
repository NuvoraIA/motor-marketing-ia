# Referencia — HyperFrames (video por código)

El editor de video del equipo. Arma videos de marca escribiendo composiciones HTML:
reels, anuncios, explainers, animaciones de datos — sin editor humano y sin timeline
que arrastrar. Repo: https://github.com/heygen-com/hyperframes

**Instalación:** ya viene. El instalador del Motor deja los skills `hyperframes`,
`hyperframes-core`, `hyperframes-cli`, `hyperframes-animation`, `hyperframes-audio`,
`hyperframes-creative`, `hyperframes-keyframes`, `hyperframes-registry`, `media-use`,
`product-launch-video` y los demás flujos del repo, más `cinematic-caption`. También
deja instalados **Node 22+ y FFmpeg**, que es lo que HyperFrames necesita para
renderizar. El CLI se usa con `npx hyperframes ...` dentro de cada proyecto.

**Punto de entrada obligatorio:** ante cualquier pedido de video, leé primero el skill
`hyperframes`. Él decide el flujo (producto, explainer, captions, slideshow, música)
y carga los skills técnicos que hagan falta. No arranques a escribir HTML de una.

## Qué puede hacer

- **Composiciones en HTML.** Una composición es un archivo HTML donde el DOM declara
  los tiempos con atributos `data-*`. Formatos: 1080×1920 vertical (reels, TikTok,
  stories), 1920×1080 horizontal (YouTube, web), cuadrado para feed.
- **Animación con GSAP** sobre una sola línea de tiempo pausada y *seek-safe*: el
  fotograma 300 se ve igual se llegue reproduciendo o saltando. Eso es lo que hace
  que el render salga determinístico. Detalle en `hyperframes-animation`.
- **Registry de ~400 bloques y componentes listos** (`npx hyperframes add <nombre>`):
  gráficas, ventanas de código, mapas, grano de película, glitch, barridos de brillo,
  confeti, transiciones. **Buscá siempre antes de construir un efecto a mano:**
  `npx hyperframes catalog --query "revelar un titular línea por línea"`.
- **Media con `media-use`:** música de fondo, efectos de sonido, imágenes, íconos,
  logos de marca, voz (TTS), transcripción, captions y quitar fondo — todo queda
  como archivo local congelado en el proyecto, no como link que se puede caer.
- **Mezcla de audio** con `hyperframes-audio`: fades, crossfade, volumen, y bajarle
  la música cuando entra la locución (*ducking*) para que la voz siempre se entienda.
- **Render local** con `npx hyperframes render --quality looks --output final.mp4`.
  Necesita Node 22+ y FFmpeg — el instalador ya los dejó puestos.
- **Render en la nube** como alternativa cuando la compu del dueño es lenta o el
  video es largo (`hyperframes cloud`). Opcional: el render local alcanza para un
  reel de 30 s.

## El ciclo de trabajo (no te lo saltes)

1. `npx hyperframes init <proyecto>` — crea el proyecto.
2. Buscá en el catálogo el efecto que querés antes de codearlo a mano.
3. Escribí la composición siguiendo `hyperframes-core`.
4. `npx hyperframes lint` mientras editás.
5. `npx hyperframes check` como control final (incluye el lint).
6. `npx hyperframes preview --background` y **mostrale el preview al dueño**.
7. Recién con el visto bueno: `npx hyperframes render`.
8. Verificá que el `.mp4` exista y no esté vacío antes de entregarlo.

## Receta de calidad (estructura recomendada)

Un video que se ve profesional suele tener: escenas encadenadas con transiciones
reales, fondo sólido oscuro con tarjetas translúcidas encima, dos tipografías (una
para títulos y otra para cuerpo), locución de ElevenLabs o de `media-use`, música
ambiente **al 10–15%** de volumen para que no tape la voz, y el logo del negocio como
marca de agua discreta.

## Workflow típico: reel de producto de 30s

1. Guion (`copywriting` + `stop-slop`) → voz (ElevenLabs `generate_audio`, o
   `media-use` si el dueño no tiene ElevenLabs conectado).
2. Imágenes/clips del producto con Higgsfield (`higgsfield-product-photoshoot`).
   Si el dueño tiene fotos propias, usá esas.
3. Proyecto HyperFrames vertical **1080×1920**: escenas con transiciones, el logo del
   cliente y los colores de marca que están en `marca.md`.
4. Subtítulos con el skill `cinematic-caption` — nunca la tira genérica de subtítulos.
   Ver `references/captions-cinematograficos.md`.
5. Música ambiente a bajo volumen (`media-use`) + SFX en las transiciones, con
   ducking bajo la voz.
6. `check` → `preview` → aprobación del dueño → `render` a `.mp4`.
7. Entregar el `.mp4` al **Social Planner de Nuvora** para programar la publicación.

## Reglas

- Respetá el kit de marca (colores, fuentes, logo) del cliente, que está en `marca.md`.
  Nunca inventes un color o un logo.
- Vertical para reels/TikTok/stories; horizontal para YouTube/web.
- **Mostrá el preview antes de renderizar.** El render es lo caro en tiempo y CPU;
  los cambios se piden sobre el preview, no sobre el `.mp4`.
- **Confirmá antes de renders largos** (más de ~2 minutos de video o lotes de varios
  videos) si el dueño no lo pidió explícitamente.
- Si el render falla, `npx hyperframes doctor` y `hyperframes-cli` diagnostican; casi
  siempre es Node viejo o FFmpeg faltante. Volvé a correr el instalador del Motor.
- Nada de recursos remotos dentro del render: fuentes, imágenes y audio tienen que
  estar como archivo local en el proyecto.
