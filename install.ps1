#
# Motor de Marketing IA - Nuvora
# Instalador de habilidades para Claude Code (Windows).
#
# Uso:
#   irm https://raw.githubusercontent.com/NuvoraIA/motor-marketing-ia/main/install.ps1 | iex
#
# No necesita Node, ni git, ni tar, ni nada instalado: solo Windows PowerShell,
# que ya viene de fabrica en Windows 10 y 11.
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

# --- Instalar un pack -------------------------------------------------------
# $Nombre = nombre lindo para mostrar   $Repo = repositorio en GitHub

function Instalar-Pack {
    param([string]$Nombre, [string]$Repo)

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

    # Una habilidad es cualquier carpeta que tenga adentro un archivo SKILL.md.
    # Algunos paquetes las guardan en skills/ y otros en la raiz: buscamos en ambos.
    $encontrados = @(
        Get-ChildItem -LiteralPath $raizRepo -Filter 'SKILL.md' -File -Recurse -Depth 2 -ErrorAction SilentlyContinue |
            Sort-Object FullName
    )

    $instaladas = 0
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

    if ($instaladas -eq 0) {
        Fallar ('El paquete "' + $Nombre + '" llegó vacío. Volvé a intentar en un rato.')
    }

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
Write-Host 'Esto tarda alrededor de un minuto. No cierres esta ventana.'
Write-Host ''

Instalar-Pack -Nombre 'Motor de Marketing IA (el cerebro que coordina todo)' -Repo 'NuvoraIA/motor-marketing-ia'
Instalar-Pack -Nombre 'Estudio de imagen y avatares'                         -Repo 'higgsfield-ai/skills'
Instalar-Pack -Nombre 'Producción de video'                                  -Repo 'remotion-dev/skills'
Instalar-Pack -Nombre 'Estrategia de marketing'                              -Repo 'coreyhaines31/marketingskills'

Limpiar

Write-Host '═══════════════════════════════════════════════════'
Write-Host ("  🎉 Listo. Tenés " + $Total + " habilidades instaladas.")
Write-Host '═══════════════════════════════════════════════════'
Write-Host ''
Write-Host 'Ahora abrí Claude Code y escribí:'
Write-Host ''
Write-Host '   Presentate y decime qué podés hacer por mi negocio hoy mismo.'
Write-Host ''
Write-Host 'Si en algún momento algo no funciona, escribile a Emilio (Nuvora).'
Write-Host ''
