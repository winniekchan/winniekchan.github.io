@echo off
rem Double-click to start the live-reload dev server (see dev-server.ps1)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev-server.ps1" %*
pause
