#!/bin/bash
#
# Motor de Marketing IA - Nuvora
# Instalador de habilidades para Claude Code.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/NuvoraIA/motor-marketing-ia/main/install.sh | bash
#
# No necesita Node, ni Homebrew, ni nada instalado: solo curl y tar,
# que ya vienen de fábrica en cualquier Mac.
#

set -u

DESTINO="$HOME/.claude/skills"
TOTAL=0
TMP=""

limpiar() {
  [ -n "$TMP" ] && [ -d "$TMP" ] && rm -rf "$TMP"
}
trap limpiar EXIT

fallar() {
  echo ""
  echo "❌ Algo no salió como esperábamos."
  echo "   $1"
  echo ""
  echo "   No se dañó nada en tu computadora. Escribile a Emilio (Nuvora)"
  echo "   para que te ayude y lo dejamos funcionando."
  echo ""
  exit 1
}

# --- Chequeos minimos -------------------------------------------------------

command -v curl >/dev/null 2>&1 || fallar "Tu Mac no encontró una herramienta necesaria para descargar."
command -v tar  >/dev/null 2>&1 || fallar "Tu Mac no encontró una herramienta necesaria para descomprimir."

mkdir -p "$DESTINO" || fallar "No se pudo preparar la carpeta donde van tus habilidades."

TMP="$(mktemp -d 2>/dev/null)" || fallar "No se pudo crear una carpeta temporal de trabajo."

# --- Instalar un pack -------------------------------------------------------
# $1 = nombre lindo para mostrar   $2 = repositorio en GitHub

instalar_pack() {
  nombre="$1"
  repo="$2"

  echo "   Descargando: $nombre ..."

  carpeta_repo="$TMP/$(echo "$repo" | tr '/' '_')"
  mkdir -p "$carpeta_repo" || fallar "No se pudo preparar el espacio para \"$nombre\"."

  paquete="$carpeta_repo.tar.gz"
  bajado=0
  for rama in main master; do
    if curl -fsSL "https://github.com/$repo/archive/refs/heads/$rama.tar.gz" \
            -o "$paquete" 2>/dev/null; then
      bajado=1
      break
    fi
  done

  if [ "$bajado" -ne 1 ]; then
    fallar "No se pudo descargar \"$nombre\". Revisá tu conexión a internet y volvé a intentar."
  fi

  if ! tar xzf "$paquete" -C "$carpeta_repo" --strip-components=1 2>/dev/null; then
    fallar "No se pudo abrir el paquete \"$nombre\". Volvé a intentar en un rato."
  fi

  # Una habilidad es cualquier carpeta que tenga adentro un archivo SKILL.md.
  # Algunos paquetes las guardan en skills/ y otros en la raíz: buscamos en ambos.
  listado="$TMP/lista.txt"
  find "$carpeta_repo" -maxdepth 3 -type f -name "SKILL.md" 2>/dev/null | sort > "$listado"

  instaladas=0
  while IFS= read -r archivo; do
    [ -n "$archivo" ] || continue
    origen="$(dirname "$archivo")"
    nombre_skill="$(basename "$origen")"

    rm -rf "$DESTINO/$nombre_skill"
    if cp -R "$origen" "$DESTINO/$nombre_skill" 2>/dev/null; then
      instaladas=$((instaladas + 1))
    else
      fallar "No se pudo guardar la habilidad \"$nombre_skill\"."
    fi
  done < "$listado"

  if [ "$instaladas" -eq 0 ]; then
    fallar "El paquete \"$nombre\" llegó vacío. Volvé a intentar en un rato."
  fi

  TOTAL=$((TOTAL + instaladas))
  if [ "$instaladas" -eq 1 ]; then
    echo "   ✅ $nombre — 1 habilidad lista"
  else
    echo "   ✅ $nombre — $instaladas habilidades listas"
  fi
  echo ""
}

# --- Arranque ---------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Motor de Marketing IA — Nuvora"
echo "  Instalando tu departamento de marketing"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Esto tarda alrededor de un minuto. No cierres esta ventana."
echo ""

instalar_pack "Motor de Marketing IA (el cerebro que coordina todo)" "NuvoraIA/motor-marketing-ia"
instalar_pack "Estudio de imagen y avatares"                         "higgsfield-ai/skills"
instalar_pack "Producción de video"                                  "remotion-dev/skills"
instalar_pack "Estrategia de marketing"                              "coreyhaines31/marketingskills"

echo "═══════════════════════════════════════════════════"
echo "  🎉 Listo. Tenés $TOTAL habilidades instaladas."
echo "═══════════════════════════════════════════════════"
echo ""
echo "Ahora abrí Claude Code y escribí:"
echo ""
echo "   Presentate y decime qué podés hacer por mi negocio hoy mismo."
echo ""
echo "Si en algún momento algo no funciona, escribile a Emilio (Nuvora)."
echo ""
