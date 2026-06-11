@echo off
title PROVISION1 - RECURSIVE IN-PLACE STERILIZATION LOOP
echo =======================================================
echo  [!] INITIALIZING RECURSIVE DESTRUCTIVE FILTER
echo  [!] TARGET: ALL SUBFOLDERS - IN-PLACE OVERWRITE
echo =======================================================
echo.

:: Resolve FFmpeg dependency locally or globally automatically
set "FFMPEG_BIN=ffmpeg"
if exist "%~dp0ffmpeg.exe" (
    set "FFMPEG_BIN=%~dp0ffmpeg.exe"
) else (
    where ffmpeg >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] ffmpeg.exe was not found.
        echo         Drop a copy of 'ffmpeg.exe' into this exact folder
        echo         next to this script, then run it again.
        echo.
        pause
        exit /b
    )
)

echo [+] FFmpeg Dependency Resolved: %FFMPEG_BIN%
echo [!] WARNING: This script will strip and overwrite files directly in their folders.
echo.
pause

:: PASS 1: TIME AND MOTION BASED MEDIA (Audio & Video - Lossless Container Sterilization)
echo [+] SCANNING SUBFOLDERS FOR AUDIO/VIDEO...
for /f "delims=" %%i in ('dir /b /s *.mp4 *.mkv *.mov *.avi *.wmv *.flac *.mp3 *.wav *.m4a *.ogg *.webm 2^>nul') do (
    if exist "%%i" (
        echo     [-] STRIPPING METADATA: %%~nxi
        "%FFMPEG_BIN%" -y -i "%%i" -c copy -map_metadata -1 -map_chapters -1 -fflags +bitexact -flags:v +bitexact -flags:a +bitexact "%%~dpni_temp%%~xi" >nul 2>&1
        
        if exist "%%~dpni_temp%%~xi" (
            del /f /q "%%i"
            move /y "%%~dpni_temp%%~xi" "%%i" >nul
        )
    )
)

:: PASS 2: STATIC IMAGE MEDIA (JPEG & PNG - Bitstream Reconstruction to Purge EXIF/XMP)
echo.
echo [+] SCANNING SUBFOLDERS FOR IMAGES...
for /f "delims=" %%i in ('dir /b /s *.jpg *.jpeg *.png 2^>nul') do (
    if exist "%%i" (
        echo     [-] PURGING EXIF/XMP/GPS: %%~nxi
        "%FFMPEG_BIN%" -y -i "%%i" -qscale:v 2 -map_metadata -1 -fflags +bitexact -flags:v +bitexact "%%~dpni_temp%%~xi" >nul 2>&1
        
        if exist "%%~dpni_temp%%~xi" (
            del /f /q "%%i"
            move /y "%%~dpni_temp%%~xi" "%%i" >nul
        )
    )
)

echo.
echo =======================================================
echo  [+] RECURSIVE STRIP COMPLETE. ALL TARGETS SANITIZED.
echo =======================================================
pause