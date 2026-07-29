# Referencia — MCP Meta Ads (Facebook / Instagram)

El media buyer del equipo. Controla la cuenta publicitaria de Meta del cliente:
crea, lee y optimiza campañas de Facebook e Instagram por completo.

## Qué puede hacer (capacidades reales del MCP)

**Estructura de campañas (crear/editar/activar):**
- `ads_create_campaign` → `ads_create_ad_set` → `ads_create_creative` → `ads_create_ad`
- `ads_update_entity` (editar), `ads_activate_entity` (activar), pausar via update
- Jerarquía Meta: **Campaña** (objetivo) → **Ad Set** (público, presupuesto, ubicaciones) → **Anuncio** (creativo)

**Creativos:**
- `ads_creative_upload_image`, `ads_creative_upload_video`, `ads_create_creative`
- `ads_get_ad_preview` para ver cómo se verá antes de publicar
- `ads_boost_ig_post` para impulsar una publicación de Instagram existente

**Públicos:**
- `ads_create_custom_audience`, `ads_update_custom_audience_users`
- Retargeting con pixel/datasets: `ads_pixel_event_*`, `ads_get_datasets`

**Lectura, reportes y optimización:**
- `ads_get_ad_accounts`, `ads_get_ad_entities` (listar campañas/adsets/ads)
- `ads_entity_get_report`, `ads_entity_schedule_report` (métricas)
- `ads_insights_performance_trend`, `ads_insights_industry_benchmark`,
  `ads_insights_anomaly_signal`, `ads_get_opportunity_score`
- `ads_experiment_abtest_create_test` (A/B tests nativos)
- `ads_library_search` (espiar anuncios de la competencia)

**Catálogo (para e-commerce / dynamic ads):**
- `ads_catalog_create`, `ads_catalog_product_create`, `ads_catalog_create_product_set`
- Dynamic ads que muestran productos según el catálogo

## Workflow típico: lanzar una campaña

1. `ads_get_ad_accounts` → confirmar cuenta y `ads_get_user_pages` → página/IG.
2. Definir objetivo (leads, mensajes, tráfico, ventas) con el skill `ads`.
3. `ads_create_campaign` (objetivo) → **déjala PAUSED**.
4. `ads_create_ad_set`: público, presupuesto diario, ubicaciones, ventana.
5. Subir creativo (`ads_creative_upload_image/video`) → `ads_create_creative`.
6. `ads_create_ad` → `ads_get_ad_preview` → 🔸 mostrar al dueño.
7. **Solo con confirmación de monto + público:** `ads_activate_entity`.
8. A los 3–7 días: `ads_entity_get_report` → reportar CPL/CPA y leads.

## Reglas
- **Nunca actives ni subas presupuesto sin confirmación explícita** (monto + público).
- Crea siempre en `PAUSED`; el dueño da luz verde.
- Reporta en lenguaje de negocio: "12 leads a $3.40 cada uno", no "8,000 impresiones".
- Usa `ads_get_errors` si algo falla; no reintentes a ciegas.
