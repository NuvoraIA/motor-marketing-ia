#!/bin/bash
#
# Motor de Marketing IA - Nuvora
# Instalador de habilidades para Claude Code.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/NuvoraIA/motor-marketing-ia/main/install.sh | bash
#
# Para las habilidades solo hacen falta curl y tar, que ya vienen de fabrica en
# cualquier Mac. Ademas dejamos listos Node y FFmpeg, que son los dos programas
# que el equipo usa para armar y exportar los videos.
#

set -u

DESTINO="$HOME/.claude/skills"
TOTAL=0
TMP=""
AVISOS=""

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

avisar() {
  echo "   ⚠️  $1"
  AVISOS="$AVISOS
   ⚠️  $1"
}

# --- Chequeos minimos -------------------------------------------------------

command -v curl >/dev/null 2>&1 || fallar "Tu Mac no encontró una herramienta necesaria para descargar."
command -v tar  >/dev/null 2>&1 || fallar "Tu Mac no encontró una herramienta necesaria para descomprimir."

mkdir -p "$DESTINO" || fallar "No se pudo preparar la carpeta donde van tus habilidades."

TMP="$(mktemp -d 2>/dev/null)" || fallar "No se pudo crear una carpeta temporal de trabajo."

# --- Preparar la computadora: Node 22+ y FFmpeg -----------------------------
# Node es el motor que corre el editor de video; FFmpeg es el que exporta el
# archivo .mp4 final. Sin estos dos, las habilidades se instalan igual pero no
# se pueden renderizar videos.

node_ok() {
  command -v node >/dev/null 2>&1 || return 1
  mayor="$(node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
  case "$mayor" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$mayor" -ge 22 ]
}

ffmpeg_ok() {
  command -v ffmpeg >/dev/null 2>&1
}

# Homebrew se instala en /opt/homebrew (Mac con chip Apple) o en /usr/local
# (Mac con chip Intel). Lo buscamos en los dos lados y lo cargamos al PATH de
# ESTA corrida, para no tener que cerrar y abrir la Terminal.
cargar_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  for candidato in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$candidato" ]; then
      eval "$("$candidato" shellenv)" >/dev/null 2>&1
      command -v brew >/dev/null 2>&1 && return 0
    fi
  done
  return 1
}

instalar_homebrew() {
  echo ""
  echo "   Tu Mac necesita Homebrew (el instalador de programas de Apple)."
  echo "   Lo vamos a instalar ahora. 👉 Te va a pedir la contraseña de tu Mac:"
  echo "      es normal, escribila y apretá Enter. No se ve mientras la escribís."
  echo ""

  if [ -r /dev/tty ]; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
      </dev/tty || return 1
  else
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  fi

  cargar_brew
}

preparar_computadora() {
  echo "▸ Preparando tu computadora (Node y FFmpeg)"
  echo ""

  falta_node=0
  falta_ffmpeg=0

  if node_ok; then
    echo "   ✅ Node — ya lo tenés ($(node -v))"
  else
    falta_node=1
  fi

  if ffmpeg_ok; then
    echo "   ✅ FFmpeg — ya lo tenés"
  else
    falta_ffmpeg=1
  fi

  if [ "$falta_node" -eq 0 ] && [ "$falta_ffmpeg" -eq 0 ]; then
    echo ""
    return 0
  fi

  if [ "$(uname -s)" != "Darwin" ]; then
    [ "$falta_node" -eq 1 ]   && avisar "Falta Node 22 o más nuevo. Instalalo con el gestor de paquetes de tu sistema."
    [ "$falta_ffmpeg" -eq 1 ] && avisar "Falta FFmpeg. Instalalo con el gestor de paquetes de tu sistema."
    avisar "Sin eso, las habilidades funcionan pero no vas a poder exportar videos."
    echo ""
    return 0
  fi

  if ! cargar_brew; then
    if ! instalar_homebrew; then
      avisar "No se pudo instalar Homebrew. Las habilidades quedan listas igual,"
      avisar "pero para exportar videos hay que instalar Node y FFmpeg. Avisale a Emilio."
      echo ""
      return 0
    fi
    echo "   ✅ Homebrew listo"
  fi

  if [ "$falta_node" -eq 1 ]; then
    echo "   Instalando Node ... (esto puede tardar unos minutos)"
    echo "   Va a aparecer texto técnico: es normal, dejalo trabajar."
    if command -v node >/dev/null 2>&1; then
      # Node está pero es viejo: primero probamos actualizarlo. Este intento va
      # callado porque si ya estaba al día imprime un error que confunde.
      brew upgrade node >/dev/null 2>&1 || brew install node || true
    else
      brew install node || true
    fi
    hash -r 2>/dev/null || true
    if node_ok; then
      echo "   ✅ Node listo ($(node -v))"
    else
      avisar "Node quedó instalado pero tu Mac todavía usa una versión vieja."
      avisar "Cerrá la Terminal, volvé a abrirla y corré esta línea de nuevo."
    fi
  fi

  if [ "$falta_ffmpeg" -eq 1 ]; then
    echo "   Instalando FFmpeg ... (esto puede tardar varios minutos)"
    echo "   Va a aparecer texto técnico: es normal, dejalo trabajar."
    # A propósito NO ocultamos la salida de brew: en una instalación de varios
    # minutos, ver que algo se mueve evita que el dueño crea que se colgó.
    brew install ffmpeg || true
    hash -r 2>/dev/null || true
    if ffmpeg_ok; then
      echo "   ✅ FFmpeg listo"
    else
      avisar "FFmpeg no quedó disponible. Cerrá la Terminal, volvé a abrirla"
      avisar "y corré esta línea de nuevo."
    fi
  fi

  echo ""
}

# --- Sacar el editor de video anterior --------------------------------------
# Quien instaló la versión vieja tiene los skills de Remotion, el editor que
# usábamos antes. Los sacamos para que no compitan con HyperFrames cuando el
# dueño pide un video. Lista explícita a propósito: nada de comodines, para no
# tocar "remotion-to-hyperframes" (ese SÍ es parte de HyperFrames).

sacar_editor_anterior() {
  viejos="remotion-best-practices remotion-captions remotion-create remotion-docs"
  viejos="$viejos remotion-interactivity remotion-maps remotion-markup"
  viejos="$viejos remotion-multimedia remotion-render remotion-saas"
  viejos="$viejos remotion-studio remotion-upgrade"

  sacados=0
  for viejo in $viejos; do
    if [ -d "$DESTINO/$viejo" ]; then
      rm -rf "$DESTINO/$viejo" 2>/dev/null && sacados=$((sacados + 1))
    fi
  done

  if [ "$sacados" -gt 0 ]; then
    echo "   🧹 Reemplazamos el editor de video anterior por HyperFrames."
    echo ""
  fi
}

# --- Instalar un pack -------------------------------------------------------
# $1 = nombre lindo para mostrar
# $2 = repositorio en GitHub
# $3 = (opcional) nombre de carpeta destino, para repos que traen el SKILL.md
#      en la raíz y quedarían con un nombre feo tipo "repo-main".

instalar_pack() {
  nombre="$1"
  repo="$2"
  destino_fijo="${3:-}"

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

  instaladas=0

  if [ -n "$destino_fijo" ]; then
    # Caso especial: el repo ES la habilidad (SKILL.md en la raíz).
    # La guardamos con nombre limpio en vez del nombre del repo.
    if [ ! -f "$carpeta_repo/SKILL.md" ]; then
      fallar "El paquete \"$nombre\" llegó incompleto. Volvé a intentar en un rato."
    fi
    rm -rf "$DESTINO/$destino_fijo"
    if cp -R "$carpeta_repo" "$DESTINO/$destino_fijo" 2>/dev/null; then
      instaladas=1
    else
      fallar "No se pudo guardar la habilidad \"$destino_fijo\"."
    fi
  else
    # Una habilidad es cualquier carpeta que tenga adentro un archivo SKILL.md.
    # Algunos paquetes las guardan en skills/ y otros en la raíz: buscamos en
    # ambos, salteando las carpetas ocultas (copias internas del repo).
    listado="$TMP/lista.txt"
    find "$carpeta_repo" -maxdepth 3 -name ".*" -prune -o \
         -type f -name "SKILL.md" -print 2>/dev/null | sort > "$listado"

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
  fi

  if [ "$instaladas" -eq 0 ]; then
    fallar "El paquete \"$nombre\" llegó vacío. Volvé a intentar en un rato."
  fi

  # No dejamos el paquete descargado ocupando espacio: algunos pesan bastante.
  rm -rf "$paquete" "$carpeta_repo" 2>/dev/null

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
echo "La primera vez esto puede tardar varios minutos: se instalan los"
echo "programas de video y se descargan todas las habilidades."
echo "No cierres esta ventana."
echo ""

preparar_computadora

echo "▸ Instalando las habilidades"
echo ""

sacar_editor_anterior

instalar_pack "Motor de Marketing IA (el cerebro que coordina todo)" "NuvoraIA/motor-marketing-ia"
instalar_pack "Estudio de imagen y avatares"                         "higgsfield-ai/skills"
instalar_pack "Producción de video (HyperFrames)"                    "heygen-com/hyperframes"
instalar_pack "Subtítulos cinematográficos"                          "audrey-560/hyperframes-cinematic-caption" "cinematic-caption"
instalar_pack "Estrategia de marketing"                              "coreyhaines31/marketingskills"

echo "═══════════════════════════════════════════════════"
echo "  🎉 Listo. Tenés $TOTAL habilidades instaladas."
echo "═══════════════════════════════════════════════════"

if [ -n "$AVISOS" ]; then
  echo ""
  echo "Ojo con esto:$AVISOS"
fi

echo ""
echo "Ahora abrí Claude Code y escribí:"
echo ""
echo "   Presentate y decime qué podés hacer por mi negocio hoy mismo."
echo ""
echo "Si en algún momento algo no funciona, escribile a Emilio (Nuvora)."
echo ""
