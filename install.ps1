#
# Motor de Marketing IA - Nuvora
# Instalador de habilidades para Claude Code (Windows).
#
# Uso:
#   irm https://raw.githubusercontent.com/NuvoraIA/motor-marketing-ia/main/install.ps1 | iex
#
# Para las habilidades solo hace falta Windows PowerShell, que ya viene de
# fabrica en Windows 10 y 11. Ademas dejamos listos Node y FFmpeg, que son los
# dos programas que el equipo usa para armar y exportar los videos.
#

# --- Preparacion del entorno ------------------------------------------------

# Barra de progreso apagada: Invoke-WebRequest baja mucho mas rapido sin ella.
$ProgressPreference = 'SilentlyContinue'

# GitHub exige TLS 1.2. Windows PowerShell 5.1 a veces arranca con TLS 1.0.
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
} catch {
    # Si no se puede ajustar, seguimos: en Windows 11 ya viene bien de fabrica.
}

# Para que los acentos y los simbolos se vean bien en la consola.
try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
} catch {
    # Si la consola no lo soporta, el texto igual se entiende.
}

$Destino = Join-Path (Join-Path $env:USERPROFILE '.claude') 'skills'
$Total = 0
$Tmp = ''
$Contador = 0
$Avisos = @()

function Limpiar {
    if ($Tmp -and (Test-Path -LiteralPath $Tmp)) {
        try { Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue } catch { }
    }
}

function Fallar {
    param([string]$Mensaje)

    Write-Host ''
    Write-Host '❌ Algo no salió como esperábamos.'
    Write-Host ("   " + $Mensaje)
    Write-Host ''
    Write-Host '   No se dañó nada en tu computadora. Escribile a Emilio (Nuvora)'
    Write-Host '   para que te ayude y lo dejamos funcionando.'
    Write-Host ''

    Limpiar

    # Pausa para que alcances a leer el mensaje antes de que se cierre la ventana.
    if ($Host.Name -eq 'ConsoleHost') {
        Write-Host '   (Apretá Enter para cerrar.)'
        try { $null = Read-Host } catch { }
    }

    exit 1
}

function Avisar {
    param([string]$Mensaje)

    Write-Host ("   ⚠️  " + $Mensaje)
    $script:Avisos = $script:Avisos + ("   ⚠️  " + $Mensaje)
}

# --- Chequeos minimos -------------------------------------------------------

if (-not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue)) {
    Fallar 'Tu Windows no encontró una herramienta necesaria para descargar.'
}
if (-not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
    Fallar 'Tu Windows no encontró una herramienta necesaria para descomprimir.'
}
if (-not $env:USERPROFILE) {
    Fallar 'No se pudo encontrar tu carpeta de usuario en esta computadora.'
}

try {
    $null = New-Item -ItemType Directory -Path $Destino -Force -ErrorAction Stop
} catch {
    Fallar 'No se pudo preparar la carpeta donde van tus habilidades.'
}

try {
    $raiz = [System.IO.Path]::GetTempPath()
    $marca = [guid]::NewGuid().ToString('N').Substring(0, 8)
    $Tmp = Join-Path $raiz ('mmia-' + $marca)
    $null = New-Item -ItemType Directory -Path $Tmp -Force -ErrorAction Stop
} catch {
    Fallar 'No se pudo crear una carpeta temporal de trabajo.'
}

# --- Preparar la computadora: Node 22+ y FFmpeg -----------------------------
# Node es el motor que corre el editor de video; FFmpeg es el que exporta el
# archivo .mp4 final. Sin estos dos, las habilidades se instalan igual pero no
# se pueden renderizar videos.

# Windows no le avisa a la ventana ya abierta que se instalo un programa nuevo:
# hay que releer el PATH del registro para verlo sin cerrar PowerShell.
function Refrescar-Path {
    try {
        $deMaquina = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $deUsuario = [Environment]::GetEnvironmentVariable('Path', 'User')
        $partes = @()
        if ($deMaquina) { $partes = $partes + $deMaquina }
        if ($deUsuario) { $partes = $partes + $deUsuario }
        if ($partes.Count -gt 0) {
            $env:Path = ($partes -join ';')
        }
    } catch {
        # Si el registro no se deja leer, seguimos con el PATH que ya teniamos.
    }
}

function Node-Ok {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $cmd) { return $false }

    try {
        $version = (& node -v 2>$null)
    } catch {
        return $false
    }
    if (-not $version) { return $false }

    $texto = ([string]$version).Trim().TrimStart('v')
    $mayor = ($texto -split '\.')[0]
    $numero = 0
    if (-not [int]::TryParse($mayor, [ref]$numero)) { return $false }

    return ($numero -ge 22)
}

function Node-Version {
    try {
        return ([string](& node -v 2>$null)).Trim()
    } catch {
        return ''
    }
}

function Ffmpeg-Ok {
    if (Get-Command ffmpeg -ErrorAction SilentlyContinue) { return $true }
    return $false
}

function Instalar-ConWinget {
    param([string]$Id, [string]$Etiqueta)

    Write-Host ("   Instalando " + $Etiqueta + " ... (esto puede tardar unos minutos)")
    Write-Host '   Va a aparecer texto técnico: es normal, dejalo trabajar.'
    try {
        # A proposito NO ocultamos la salida de winget: en una instalacion de
        # varios minutos, ver que algo se mueve evita que el duenio crea que
        # se colgo y cierre la ventana.
        & winget install --id $Id -e --source winget --silent `
            --accept-package-agreements --accept-source-agreements
    } catch {
        # El resultado real lo verificamos abajo, no por el codigo de salida.
    }
    Refrescar-Path
}

function Preparar-Computadora {
    Write-Host '▸ Preparando tu computadora (Node y FFmpeg)'
    Write-Host ''

    Refrescar-Path

    $faltaNode = $true
    $faltaFfmpeg = $true

    if (Node-Ok) {
        Write-Host ("   ✅ Node — ya lo tenés (" + (Node-Version) + ")")
        $faltaNode = $false
    }
    if (Ffmpeg-Ok) {
        Write-Host '   ✅ FFmpeg — ya lo tenés'
        $faltaFfmpeg = $false
    }

    if ((-not $faltaNode) -and (-not $faltaFfmpeg)) {
        Write-Host ''
        return
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Avisar 'Tu Windows no tiene "winget" (el instalador de apps de Microsoft).'
        Avisar 'Las habilidades quedan listas igual, pero para exportar videos'
        Avisar 'hay que instalar Node y FFmpeg a mano. Avisale a Emilio.'
        Write-Host ''
        return
    }

    Write-Host '   Windows te puede pedir permiso para instalar: dale "Sí".'

    if ($faltaNode) {
        Instalar-ConWinget -Id 'OpenJS.NodeJS.LTS' -Etiqueta 'Node'
        if (Node-Ok) {
            Write-Host ("   ✅ Node listo (" + (Node-Version) + ")")
        } else {
            Avisar 'Node quedó instalado, pero esta ventana de PowerShell todavía no lo ve.'
            Avisar 'Cerrá PowerShell, volvé a abrirlo y corré la línea de nuevo.'
        }
    }

    if ($faltaFfmpeg) {
        Instalar-ConWinget -Id 'Gyan.FFmpeg' -Etiqueta 'FFmpeg'
        if (Ffmpeg-Ok) {
            Write-Host '   ✅ FFmpeg listo'
        } else {
            Avisar 'FFmpeg quedó instalado, pero esta ventana de PowerShell todavía no lo ve.'
            Avisar 'Cerrá PowerShell, volvé a abrirlo y corré la línea de nuevo.'
        }
    }

    Write-Host ''
}

# --- Descomprimir -----------------------------------------------------------

function Descomprimir {
    param([string]$Paquete, [string]$Carpeta)

    try {
        Expand-Archive -Path $Paquete -DestinationPath $Carpeta -Force -ErrorAction Stop
        return $true
    } catch {
        # Plan B por si Expand-Archive se traba con algun archivo.
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
            [System.IO.Compression.ZipFile]::ExtractToDirectory($Paquete, $Carpeta)
            return $true
        } catch {
            return $false
        }
    }
}

# --- Sacar el editor de video anterior --------------------------------------
# Quien instalo la version vieja tiene los skills de Remotion, el editor que
# usabamos antes. Los sacamos para que no compitan con HyperFrames cuando el
# duenio pide un video. Lista explicita a proposito: nada de comodines, para no
# tocar "remotion-to-hyperframes" (ese SI es parte de HyperFrames).

function Sacar-EditorAnterior {
    $viejos = @(
        'remotion-best-practices', 'remotion-captions', 'remotion-create',
        'remotion-docs', 'remotion-interactivity', 'remotion-maps',
        'remotion-markup', 'remotion-multimedia', 'remotion-render',
        'remotion-saas', 'remotion-studio', 'remotion-upgrade'
    )

    $sacados = 0
    foreach ($viejo in $viejos) {
        $ruta = Join-Path $Destino $viejo
        if (Test-Path -LiteralPath $ruta) {
            try {
                Remove-Item -LiteralPath $ruta -Recurse -Force -ErrorAction Stop
                $sacados = $sacados + 1
            } catch { }
        }
    }

    if ($sacados -gt 0) {
        Write-Host '   🧹 Reemplazamos el editor de video anterior por HyperFrames.'
        Write-Host ''
    }
}

# --- Instalar un pack -------------------------------------------------------
# $Nombre       = nombre lindo para mostrar
# $Repo         = repositorio en GitHub
# $DestinoFijo  = (opcional) nombre de carpeta destino, para repos que traen el
#                 SKILL.md en la raiz y quedarian con un nombre feo "repo-main".

function Instalar-Pack {
    param([string]$Nombre, [string]$Repo, [string]$DestinoFijo = '')

    Write-Host ("   Descargando: " + $Nombre + " ...")

    $script:Contador = $script:Contador + 1
    $carpetaRepo = Join-Path $Tmp ('r' + $script:Contador)
    try {
        $null = New-Item -ItemType Directory -Path $carpetaRepo -Force -ErrorAction Stop
    } catch {
        Fallar ('No se pudo preparar el espacio para "' + $Nombre + '".')
    }

    $paquete = $carpetaRepo + '.zip'
    $bajado = $false
    foreach ($rama in @('main', 'master')) {
        $url = 'https://github.com/' + $Repo + '/archive/refs/heads/' + $rama + '.zip'
        try {
            Invoke-WebRequest -Uri $url -OutFile $paquete -UseBasicParsing -ErrorAction Stop
            $bajado = $true
            break
        } catch {
            $bajado = $false
        }
    }

    if (-not $bajado) {
        Fallar ('No se pudo descargar "' + $Nombre + '". Revisá tu conexión a internet y volvé a intentar.')
    }

    if (-not (Descomprimir -Paquete $paquete -Carpeta $carpetaRepo)) {
        Fallar ('No se pudo abrir el paquete "' + $Nombre + '". Volvé a intentar en un rato.')
    }

    # El zip de GitHub envuelve todo en una carpeta REPO-main. Entramos ahi.
    $raizRepo = $carpetaRepo
    $adentro = @(Get-ChildItem -LiteralPath $carpetaRepo -Directory -ErrorAction SilentlyContinue)
    if ($adentro.Count -eq 1) {
        $raizRepo = $adentro[0].FullName
    }

    $instaladas = 0

    if ($DestinoFijo) {
        # Caso especial: el repo ES la habilidad (SKILL.md en la raiz).
        # La guardamos con nombre limpio en vez del nombre del repo.
        if (-not (Test-Path -LiteralPath (Join-Path $raizRepo 'SKILL.md'))) {
            Fallar ('El paquete "' + $Nombre + '" llegó incompleto. Volvé a intentar en un rato.')
        }

        $final = Join-Path $Destino $DestinoFijo
        try {
            if (Test-Path -LiteralPath $final) {
                Remove-Item -LiteralPath $final -Recurse -Force -ErrorAction Stop
            }
            Copy-Item -LiteralPath $raizRepo -Destination $final -Recurse -Force -ErrorAction Stop
            $instaladas = 1
        } catch {
            Fallar ('No se pudo guardar la habilidad "' + $DestinoFijo + '".')
        }
    } else {
        # Una habilidad es cualquier carpeta que tenga adentro un archivo SKILL.md.
        # Algunos paquetes las guardan en skills/ y otros en la raiz: buscamos en
        # ambos, salteando las carpetas ocultas (copias internas del repo).
        $encontrados = @(
            Get-ChildItem -LiteralPath $raizRepo -Filter 'SKILL.md' -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
                Where-Object { -not ($_.FullName.Substring($raizRepo.Length) -match '[\\/]\.') } |
                Sort-Object FullName
        )

        foreach ($archivo in $encontrados) {
            $origen = $archivo.Directory.FullName
            $nombreSkill = $archivo.Directory.Name
            $final = Join-Path $Destino $nombreSkill

            try {
                if (Test-Path -LiteralPath $final) {
                    Remove-Item -LiteralPath $final -Recurse -Force -ErrorAction Stop
                }
                Copy-Item -LiteralPath $origen -Destination $final -Recurse -Force -ErrorAction Stop
                $instaladas = $instaladas + 1
            } catch {
                Fallar ('No se pudo guardar la habilidad "' + $nombreSkill + '".')
            }
        }
    }

    if ($instaladas -eq 0) {
        Fallar ('El paquete "' + $Nombre + '" llegó vacío. Volvé a intentar en un rato.')
    }

    # No dejamos el paquete descargado ocupando espacio: algunos pesan bastante.
    try { Remove-Item -LiteralPath $paquete -Force -ErrorAction SilentlyContinue } catch { }
    try { Remove-Item -LiteralPath $carpetaRepo -Recurse -Force -ErrorAction SilentlyContinue } catch { }

    $script:Total = $script:Total + $instaladas
    if ($instaladas -eq 1) {
        Write-Host ("   ✅ " + $Nombre + " — 1 habilidad lista")
    } else {
        Write-Host ("   ✅ " + $Nombre + " — " + $instaladas + " habilidades listas")
    }
    Write-Host ''
}

# --- Arranque ---------------------------------------------------------------

Write-Host ''
Write-Host '═══════════════════════════════════════════════════'
Write-Host '  Motor de Marketing IA — Nuvora'
Write-Host '  Instalando tu departamento de marketing'
Write-Host '═══════════════════════════════════════════════════'
Write-Host ''
Write-Host 'La primera vez esto puede tardar varios minutos: se instalan los'
Write-Host 'programas de video y se descargan todas las habilidades.'
Write-Host 'No cierres esta ventana.'
Write-Host ''

Preparar-Computadora

Write-Host '▸ Instalando las habilidades'
Write-Host ''

Sacar-EditorAnterior

Instalar-Pack -Nombre 'Motor de Marketing IA (el cerebro que coordina todo)' -Repo 'NuvoraIA/motor-marketing-ia'
Instalar-Pack -Nombre 'Estudio de imagen y avatares'                         -Repo 'higgsfield-ai/skills'
Instalar-Pack -Nombre 'Producción de video (HyperFrames)'                    -Repo 'heygen-com/hyperframes'
Instalar-Pack -Nombre 'Subtítulos cinematográficos'                          -Repo 'audrey-560/hyperframes-cinematic-caption' -DestinoFijo 'cinematic-caption'
Instalar-Pack -Nombre 'Estrategia de marketing'                              -Repo 'coreyhaines31/marketingskills'

Limpiar

Write-Host '═══════════════════════════════════════════════════'
Write-Host ("  🎉 Listo. Tenés " + $Total + " habilidades instaladas.")
Write-Host '═══════════════════════════════════════════════════'

if ($Avisos.Count -gt 0) {
    Write-Host ''
    Write-Host 'Ojo con esto:'
    foreach ($aviso in $Avisos) {
        Write-Host $aviso
    }
}

Write-Host ''
Write-Host 'Ahora abrí Claude Code y escribí:'
Write-Host ''
Write-Host '   Presentate y decime qué podés hacer por mi negocio hoy mismo.'
Write-Host ''
Write-Host 'Si en algún momento algo no funciona, escribile a Emilio (Nuvora).'
Write-Host ''
