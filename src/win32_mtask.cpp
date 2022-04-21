#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

#include <Windows.h>
#include <processenv.h>
#include <shellapi.h>
#include <shlwapi.h>

#include "win32_msvc.cpp"

static int ArgumentCount;
static LPWSTR *CommandLineArguments;

static void
Print(const WCHAR *Message, ...)
{

    HANDLE ConsoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);

    va_list Arguments;
    va_start(Arguments, Message);

    WCHAR Buffer[1024];
    DWORD Length = wvsprintfW(Buffer, Message, Arguments);

    if (GetFileType(ConsoleHandle) == FILE_TYPE_CHAR)
    {
        DWORD Written;
        WriteConsoleW(ConsoleHandle, Buffer, Length, &Written, NULL);
    }
    else
    {
        WriteFile(ConsoleHandle, Buffer, Length, &Written, NULL);
    }
    
    va_end(Arguments);
}

static void
Usage(LPCWSTR Command = 0)
{
    if (Command)
    {
        Print(L"Usage: for command %s\n", Command);
    }
    else
    {
        Print(L"Usage: Instructions");
    }
}

void __stdcall mainCRTStartup()
{

    CommandLineArguments = CommandLineToArgvW(GetCommandLineW(), &ArgumentCount);

    if (ArgumentCount < 2)
    {
        Usage();
    }

    LPCWSTR Command = CommandLineArguments[1];

    if (StrCmpW(Command, L"help") == 0)
    {
        if (ArgumentCount == 3)
        {
            Usage(CommandLineArguments[2]);
        }
        else
        {
            Usage();
        }
    }

}
