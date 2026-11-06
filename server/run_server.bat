@echo off
title Server AI Tampil - Groq
cd /d "%~dp0"

REM Baca variabel dari file .env jika ada
if exist .env (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set "%%a=%%b"
    )
)

echo ==============================================
echo   MENJALANKAN SERVER AI TAMPIL (GROQ)
echo ==============================================
echo   Direktori: %CD%
echo   Port: http://localhost:8000
echo   Docs: http://localhost:8000/docs
echo ==============================================
python -m uvicorn server:app --host 0.0.0.0 --port 8000 --reload
pause
