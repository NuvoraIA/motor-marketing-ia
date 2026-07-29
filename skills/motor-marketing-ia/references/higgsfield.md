# Referencia — Higgsfield (imagen, avatares, video, creativos)

El estudio creativo del equipo. Genera imágenes, avatares con identidad, fotos de
producto de calidad de marca, videos y ads. Se instala con los skills oficiales:

```bash
npx skills add higgsfield-ai/skills
```

## Los skills que instala y para qué sirve cada uno

| Skill | Úsalo para | Trigger típico del dueño |
|---|---|---|
| **higgsfield-generate** | Generar imagen/video/3D/audio genérico, image-to-video, remix, ads con Marketing Studio | "hazme una imagen", "anima esta foto", "haz un clip" |
| **higgsfield-product-photoshoot** | Fotos de producto tipo estudio, lifestyle, hero/banner, carrusel, ad creative, virtual try-on | "foto de producto", "shot de estudio", "creativo para Meta" |
| **higgsfield-marketplace-cards** | Cards de listing para marketplace: imagen principal compliant, secundarias, A+ | "imágenes para mi listing", "product cards" |
| **higgsfield-soul-id** | Entrenar un "Soul" = modelo de la cara de una persona para identidad fiel | "entrena mi cara", "mi avatar / gemelo digital" |

## Flujo de identidad (avatar del dueño o del producto)

1. **Una vez:** `higgsfield-soul-id` entrena la cara del dueño/modelo → devuelve un
   `reference_id`. (O usa una foto de referencia directa para one-shot.)
2. **Cada vez:** `higgsfield-generate` con `--soul-id <id>` para que el avatar salga
   consistente en cada imagen/video (misma persona, misma cara).
3. Para producto: `higgsfield-product-photoshoot` con la foto del producto del cliente
   (modos: `product_shot`, `lifestyle_scene`, `closeup_product_with_person`,
   `ad_creative_pack`, `virtual_model_tryout`, etc.).

## Cuándo cuál
- **Producto solo / marca:** `higgsfield-product-photoshoot`.
- **Persona/avatar hablando o presentando:** `higgsfield-soul-id` + `higgsfield-generate`.
- **Listing de Amazon/marketplace:** `higgsfield-marketplace-cards`.
- **Un ad UGC o de presentador:** `higgsfield-generate` (Marketing Studio).

## Reglas
- Carga el kit de marca (`marca.md`): colores, logo, estilo — no improvises.
- Confirma antes de lotes grandes (consumen créditos).
- Toda imagen que vaya a pauta debe verse como el negocio real, no stock genérico.
- Encadena con ElevenLabs (voz) + Remotion (ensamblado) para video completo.
