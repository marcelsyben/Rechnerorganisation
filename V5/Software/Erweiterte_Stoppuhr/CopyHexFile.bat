@echo off

rem Zum richtigen Laufwerk wechseln (aus %0 ermittelt)
%~d0

rem In das Projekt-Verzeichnis wechseln (aus %0 ermittelt)
cd %~p0

rem Projektname ermitteln
for /f "delims=\\" %%I in ('cd') do set PROJECT=%%~nxI

rem Altes Hex-File loeschen
del ..\..\Hardware\Speicher\Software.hex


set SOURCE=Debug\%PROJECT%.hex
set DEST=..\..\Hardware\Speicher\Software.hex

echo Kopiere %SOURCE% nach %DEST% 

rem Neues Hex-File kopieren
copy %SOURCE% %DEST%

pause
