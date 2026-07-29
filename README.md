# Motor de Marketing IA 🧠

Un **departamento de marketing completo** dentro de Claude Code. No es un chatbot que
escribe textos: es un estratega que decide, crea y ejecuta coordinando seis
herramientas de IA como si fueran su equipo.

Creado por [Nuvora](https://nuvorahn.com) para negocios de servicios y de productos.

---

## Qué hace

| Necesidad | Lo que hace por vos | Reemplaza a |
|---|---|---|
| **Pauta** | Crea, lee y optimiza campañas de Facebook e Instagram | Media buyer |
| **Imagen** | Fotos de producto y avatares con tu marca, ilimitados | Estudio + diseñador |
| **Voz** | Locuciones en español desde texto | Locutor |
| **Video** | Reels y anuncios renderizados con código | Editor de video |
| **Publicación** | Programa y publica en tus redes | Community manager |
| **Estrategia** | Copy, ángulos, CRO, email, precios | Estratega de marketing |

Vos pedís en lenguaje normal — *"hazme un anuncio para mi promo de fin de mes"* — y el
sistema corre el pipeline completo: estrategia → copy → imagen → voz → video →
publicación → pauta → medición.

## Instalación

```bash
npx skills add nuvoraIA/motor-marketing-ia
```

### Requisitos

Este skill **orquesta** herramientas; necesita que estén conectadas para trabajar.
Conectá las que vayas a usar:

**Conectores (MCP)** — se agregan en *Ajustes → Conectores*:

| Herramienta | Endpoint |
|---|---|
| Meta Ads | `https://mcp.facebook.com/ads` |
| Higgsfield | `https://mcp.higgsfield.ai/mcp` |
| CRM (Social Planner) | `https://services.leadconnectorhq.com/mcp/anthropic/v2` |

**ElevenLabs** se conecta con tu API key (la sacás en elevenlabs.io → API Keys):

```bash
claude mcp add elevenlabs -e ELEVENLABS_API_KEY=TU_CLAVE -- uvx elevenlabs-mcp
```

**Habilidades complementarias:**

```bash
npx skills add higgsfield-ai/skills
npx skills add remotion-dev/skills
npx skills add coreyhaines31/marketingskills
```

> No hace falta tenerlas todas. Si alguna no está conectada, el sistema te lo dice y
> sigue trabajando con las que sí funcionan.

## Cómo empezar

Después de instalar, escribile:

```
Presentate y decime qué podés hacer por mi negocio hoy mismo.
```

La primera vez te va a hacer unas preguntas sobre tu negocio (qué vendés, a quién, tus
colores, tu tono) y **guarda las respuestas solo** para no volver a preguntártelas. A
partir de ahí, todo lo que produzca sale con tu identidad, no genérico.

## Cómo trabaja

- **Nunca activa pauta ni sube presupuesto** sin confirmarte el monto y el público.
  Las campañas se crean pausadas hasta que vos les des luz verde.
- **Nunca publica contenido público** sin tu aprobación.
- **Nunca inventa** precios, garantías ni casos de éxito. Si no lo sabe, pregunta.
- Todo el texto pasa por un filtro anti-IA para que no suene a robot.

## Soporte

Instalación, capacitación y soporte: **[nuvorahn.com](https://nuvorahn.com)**

---

*Motor de Marketing IA™ · Nuvora*
