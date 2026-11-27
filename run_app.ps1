# ============================================================
# Jalankan aplikasi TAMPIL + server AI otomatis.
#
# Server FastAPI (port 8000) dicek dulu; kalau mati langsung
# dinyalakan di latar belakang sebelum `flutter run` dimulai,
# jadi transkripsi suara tidak lagi gagal karena server offline.
#
# Cara pakai (PowerShell, dari folder proyek):
#   .\run_app.ps1                        -> nyalakan server + flutter run
#   .\run_app.ps1 -Device emulator       -> pilih perangkat (flutter devices)
#   .\run_app.ps1 -ServerUrl auto        -> deteksi IP LAN PC, disuntikkan
#                                          sebagai AI_SERVER_URL (untuk HP
#                                          fisik agar bisa akses server PC)
#   .\run_app.ps1 -ServerOnly            -> cukup nyalakan servernya saja
#   .\run_app.ps1 -NoServer              -> flutter run tanpa menyentuh server
# ============================================================

param(
    [string]$Device = '',
    [string]$ServerUrl = '',
    [switch]$NoServer,
    [switch]$ServerOnly
)

$ErrorActionPreference = 'Stop'
$akar = $PSScriptRoot

# --- Cek apakah server AI sudah hidup di port 8000 ------------
function Test-ServerAi {
    try {
        $res = Invoke-WebRequest -Uri 'http://127.0.0.1:8000/' -UseBasicParsing -TimeoutSec 2
        return $res.StatusCode -eq 200
    } catch {
        return $false
    }
}

# --- Nyalakan server bila mati --------------------------------
if (-not $NoServer) {
    if (Test-ServerAi) {
        Write-Host 'Server AI sudah hidup di port 8000, tidak perlu dinyalakan.' -ForegroundColor Green
    } else {
        Write-Host 'Menyalakan server AI FastAPI di latar belakang...' -ForegroundColor Cyan
        Start-Process powershell -ArgumentList '-NoProfile', '-Command', `
            "cd `"$akar\server`"; python -m uvicorn server:app --host 0.0.0.0 --port 8000" `
            -WindowStyle Minimized

        # Tunggu sampai sehat, maksimal 20 detik
        $tunggu = 0
        while (-not (Test-ServerAi) -and $tunggu -lt 20) {
            Start-Sleep -Seconds 1
            $tunggu++
        }

        if (Test-ServerAi) {
            Write-Host 'Server AI hidup (http://localhost:8000).' -ForegroundColor Green
        } else {
            Write-Warning 'Server AI gagal hidup dalam 20 detik. Cek window PowerShell server (mungkin dependency python belum terpasang).'
        }
    }
}

if ($ServerOnly) { exit 0 }

# --- Susun argumen flutter run --------------------------------
$argumen = @('run')
if ($Device -ne '') { $argumen += @('-d', $Device) }

# Untuk HP fisik, 'localhost' di HP bukan PC. -ServerUrl auto
# mencari IP LAN PC lalu meneruskannya lewat --dart-define.
if ($ServerUrl -ne '') {
    $url = $ServerUrl
    if ($ServerUrl -eq 'auto') {
        $ip = Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
            Sort-Object -Property InterfaceMetric |
            Select-Object -First 1 -ExpandProperty IPAddress
        if ($null -eq $ip) {
            Write-Warning 'IP LAN tidak terdeteksi, memakai localhost (hanya berlaku untuk emulator/web di PC ini).'
            $url = 'http://localhost:8000'
        } else {
            $url = "http://${ip}:8000"
        }
    }
    $argumen += "--dart-define=AI_SERVER_URL=$url"
    Write-Host "AI_SERVER_URL disuntikkan: $url" -ForegroundColor Cyan
}

Write-Host "Menjalankan: flutter $($argumen -join ' ')" -ForegroundColor Cyan
Push-Location $akar
try {
    & flutter @argumen
    $kode = $LASTEXITCODE
} finally {
    Pop-Location
}

exit $kode
