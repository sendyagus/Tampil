# ============================================================
# Build aplikasi TAMPIL dengan AI langsung di dalam aplikasi.
#
# Skrip ini mengambil GROQ_API_KEY dari server\.env (tidak pernah ikut
# ter-commit karena .env masuk .gitignore), lalu menyuntikkannya ke build
# lewat --dart-define. Hasilnya: aplikasi yang sudah terpasang tidak perlu
# menyalakan server Python sama sekali, cukup koneksi internet.
#
# Cara pakai (PowerShell, dari folder proyek):
#   .\build_ai.ps1                 -> build APK
#   .\build_ai.ps1 -Run            -> build lalu install & jalankan ke perangkat
#   .\build_ai.ps1 -Target web     -> build web
#   .\build_ai.ps1 -DirectOff      -> paksa aplikasi tetap pakai server lokal
# ============================================================

param(
    [ValidateSet('apk', 'web', 'windows')]
    [string]$Target = 'apk',
    [switch]$Run,
    [switch]$DirectOff
)

$ErrorActionPreference = 'Stop'
$akar = $PSScriptRoot

# --- Ambil kunci Groq dari server\.env -----------------------
$fileEnv = Join-Path $akar 'server\.env'
$kunci = ''

if (Test-Path $fileEnv) {
    foreach ($baris in Get-Content $fileEnv) {
        $teks = $baris.Trim()
        if ($teks -eq '' -or $teks.StartsWith('#')) { continue }
        if ($teks -match '^GROQ_API_KEY\s*=\s*(.+)$') {
            $kunci = $Matches[1].Trim().Trim('"').Trim("'")
            break
        }
    }
}

if ($kunci -eq '') {
    Write-Warning 'GROQ_API_KEY tidak ditemukan di server\.env.'
    Write-Warning 'Aplikasi akan kembali memakai server lokal (port 8000).'
}

# --- Susun argumen build -------------------------------------
$dartDefine = @()
if ($kunci -ne '') { $dartDefine += "GROQ_API_KEY=$kunci" }
if (-not $DirectOff) { $dartDefine += 'AI_MODE=direct' }

$argumen = @('build', $Target)
foreach ($d in $dartDefine) { $argumen += "--dart-define=$d" }

if ($Run) {
    $argumen = @('run', '-d', 'any')
    foreach ($d in $dartDefine) { $argumen += "--dart-define=$d" }
}

# Kunci sengaja disamarkan agar tidak menumpuk di riwayat terminal.
$tampilan = ($argumen -join ' ') -replace 'GROQ_API_KEY=\S+', 'GROQ_API_KEY=***'
Write-Host "Menjalankan: flutter $tampilan" -ForegroundColor Cyan
Push-Location $akar
try {
    & flutter @argumen
    $kode = $LASTEXITCODE
} finally {
    Pop-Location
}

if ($kode -ne 0) { exit $kode }

if (-not $Run) {
    Write-Host ''
    Write-Host 'Selesai. AI menyala langsung dari aplikasi (tanpa server).' -ForegroundColor Green
    Write-Host 'Catatan: kunci Groq ikut ter-bundle di dalam aplikasi. Untuk'
    Write-Host 'proyek kuliah ini diterima, tetapi jangan gunakan key produksi.'
}
