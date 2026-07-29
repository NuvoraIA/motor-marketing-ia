# Referencia — Remotion (video programático)

El editor de video del equipo. Crea videos de marca renderizados con React/código:
reels, anuncios, explainers, animaciones de datos — sin editor humano. Docs:
https://www.remotion.dev/docs

**Instalación (un solo skill):** `npx skills add remotion-dev/skills` — instala
`remotion-best-practices`, que cubre setup del proyecto + mejores prácticas. El
framework Remotion se instala solo por proyecto al crear un video; no hay paso aparte.

## Qué puede hacer
- Composiciones de video (1920×1080, 1080×1920 vertical para reels/TikTok, 30fps).
- Animación con `interpolate`, `spring`, `useCurrentFrame`; transiciones con
  `TransitionSeries`; texto, formas, liquid glass, efectos 3D, rutas SVG, noise.
- Ensamblar imagen (Higgsfield) + voz (ElevenLabs) + música en un video final.
- Render a `.mp4` reproducible.
- Base de conocimiento completa de APIs en la memoria `remotion_knowledge.md`.

## Receta de calidad (estructura recomendada)
Un video que se ve profesional suele tener: escenas encadenadas con `TransitionSeries`,
fondo sólido oscuro con tarjetas translúcidas encima, dos tipografías (una para
títulos y otra para cuerpo), locución de ElevenLabs, música ambiente **al 10–15%** de
volumen para que no tape la voz, y el logo del negocio como marca de agua discreta.

## Workflow típico: reel de producto de 30s
1. Guion (`copywriting` + `stop-slop`) → voz (`ElevenLabs generate_audio`).
2. Imágenes/clips del producto (`higgsfield-product-photoshoot`).
3. Composición Remotion vertical 1080×1920: escenas con `TransitionSeries`,
   subtítulos quemados, logo del cliente, colores de marca de `marca.md`.
4. Música ambient a bajo volumen; SFX en transiciones.
5. Render `.mp4` → entregar al **Social Planner de Nuvora** para programar.

## Reglas
- Respeta el kit de marca (colores, fuentes, logo) del cliente.
- Vertical para reels/TikTok/stories; horizontal para YouTube/web.
- `prefers-reduced-motion` no aplica a video, pero evita parpadeos agresivos.
- Renders largos consumen tiempo/CPU: confirma antes de renders >2 min.
