@echo off
setlocal enabledelayedexpansion

REM Find and setup vs build tools.
where /Q cl.exe || (
    for /f "tokens=*" %%i in ('"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath') do set VisualStudio=%%i
    if "!VisualStudio!" equ "" (
        echo ERROR: Visual Studio installation not found
        exit /b 1
    )
    call "!VisualStudio!\VC\Auxiliary\Build\vcvarsall.bat" x64 || exit /b
)

set COMMON_LIBS= kernel32.lib user32.lib shell32.lib shlwapi.lib

if "%1" equ "release" (
    set COMPILE_FLAGS= /nologo /O1 /W4 /WX /Gm- /GR- /GS- /EHa- /Oi
    set LINK_FLAGS= /opt:ref /opt:icf /subsystem:console %COMMON_LIBS%
) else (
    set COMPILE_FLAGS= /nologo /Od /W4 /WX /MTd /Gm- /GR- /GS- /EHa- /Zo /Oi /Zi /FC /wd4706 /wd4100 /wd4505
    set LINK_FLAGS= /opt:ref /incremental:no /Debug:full /subsystem:console %COMMON_LIBS%
)
if not exist build mkdir build
pushd build

cl.exe %COMPILE_FLAGS% -D_CRT_SECURE_NO_WARNINGS=1 ../src/win32_mtask.cpp /link %LINK_FLAGS% /out:mtask.exe

popd
