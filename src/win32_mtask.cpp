#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

#include <Windows.h>
#include <processenv.h>
#include <shellapi.h>

#include "win32_msvc.cpp"

void __stdcall WinMainCRTStartup()
{

    int ArgCount = 0;
    LPWSTR *CommandLine = CommandLineToArgvW(GetCommandLineW(), &ArgCount);

    LPWSTR CommandLineTest = CommandLine[0];
    OutputDebugStringW(CommandLineTest);
}
