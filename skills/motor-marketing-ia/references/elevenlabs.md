# Referencia — ElevenLabs (voz e IA de audio)

El locutor del equipo. Convierte texto en voz natural en español, crea/gestiona
voces, dobla, y genera música/efectos.

**Conexión (por API key — método confiable):** si el conector remoto no engancha, corré
el servidor local con la API key del cliente:
`claude mcp add elevenlabs -e ELEVENLABS_API_KEY=TU_CLAVE -- uvx elevenlabs-mcp`.
La clave se saca en elevenlabs.io → API Keys. Verificá con `list_voices`.

## Qué puede hacer (capacidades reales)

**Voz desde texto:**
- `generate_audio` — texto → voz (locución para reels, anuncios, videos).
- `list_voices` — ver las voces disponibles; `create_voice` — clonar/crear una voz
  de marca; `voice_change` — cambiar la voz de un audio.

**Audio / música / efectos:**
- `generate_audio` también para música y SFX (según prompt).
- `dubbing` — doblar un video a otro idioma.

**Producción de contenido (studios):**
- `explainer_video`, `shorts_studio_create`, `personal_clipper_create`
- `show_marketing_studio` — assets de marketing con audio.

**Publicación directa (opcional):**
- `tiktok_connect` / `tiktok_publish` — publicar a TikTok (además del Social Planner
  de Nuvora). `tiktok_music_trending` para audio en tendencia.

## Voz de marca
Elige (o clona) **una sola voz** para el negocio la primera vez, y guarda su `voice_id`
en `marca.md`. Reúsala siempre: la consistencia de voz es parte de la identidad de
marca — cambiarla en cada video se nota y resta profesionalismo.

## Workflow típico: locución para un reel

1. Escribe el guion con `copywriting` + pásalo por `stop-slop`.
2. `list_voices` → elige la voz de marca (o la que el dueño prefiera).
3. `generate_audio` con el guion en español (voseo/tuteo según el país del cliente).
4. Entrega el audio a **Remotion** para ensamblar con imagen/video y música.

## Reglas
- Idioma y acento correctos para el mercado del cliente (Honduras/LATAM = voseo o
  neutro según el negocio).
- Confirma la voz de marca una sola vez y reúsala.
- No clones voces de terceros sin permiso.
- **Rota las API keys** si alguna se expone en un chat.
