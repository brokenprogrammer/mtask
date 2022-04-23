#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "win32_mtask.h"

#include "serialize.h"

#include "serialize.cpp"

static void
Usage(char *Command = 0)
{
    if (Command)
    {
        printf("Usage: for command %s\n", Command);
    }
    else
    {
        printf("Usage: Instructions");
    }
}


// Command ideas:
// mstask [command] [id?] [modifiers]
// Example: mstask add task "Implement new feature" +tag
//
// Commands:
// set [option] [value] | Example: set workspace Nullsson
// add
// start
// stop
// done / complete
// note
// list
// sync
// update
// help

static mtask_config
CreateConfiguration()
{
    mtask_config Config = {0};

    char WorkSpaceName[512];
    printf("Enter a name for your workspace: ");
    scanf("%s", &WorkSpaceName);

    // NOTE(Oskar): Create file
    FILE *FilePointer;
    if (FilePointer = fopen("mtask.conf", "w"))
    {
        Config.ActiveWorkspaceName = WorkSpaceName;
        Config.ActiveWorkspaceNameLength = (uint32_t)strlen(WorkSpaceName);
        Config.Loaded = true;
            
        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = true;
        LBPSerializer.FilePointer = FilePointer;
        if (SerializeIncludingVersion(&LBPSerializer, &Config))
        {
            printf("Successfully created a new configuration file!\n");
        }
        else
        {
            printf("Failed to write config file.\n");
        }
        
        fclose(FilePointer);
    }
    else
    {
        printf("Could not create config file.\n");
    }
    
    return Config;
}

static mtask_config
LoadConfiguration()
{    
    mtask_config Config = {0};

    FILE *FilePointer;
    if (FilePointer = fopen("mtask.conf", "r"))
    {
        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = false;
        LBPSerializer.FilePointer = FilePointer;
        if (SerializeIncludingVersion(&LBPSerializer, &Config))
        {
            Config.Loaded = true;
        }
        else
        {
            printf("Failed to read config file\n");
        }
        fclose(FilePointer);
    }
    else
    {
        printf("No configuration file was found, do you wish to create one? (y/n): ");

        char Answer;
        scanf("%c", &Answer);

        if (Answer == 'y' ||
            Answer == 'Y')
        {
            return CreateConfiguration();
        }
    }
    
    return Config;
}

int main(int ArgumentCount, char **Arguments)
{
    if (ArgumentCount < 2)
    {
        Usage();
    }

    // NOTE(Oskar): Load configuration
    mtask_config Configuration = LoadConfiguration();

    int CurrentArgument = 1;
    char *Command = Arguments[CurrentArgument++];

    if (strcmp(Command, "help") == 0)
    {
        // help [command?]
        if (ArgumentCount == 3)
        {
            Usage(Arguments[CurrentArgument++]);
        }
        else
        {
            Usage();
        }
    }
    else if (strcmp(Command, "set") == 0)
    {
        // set [option] [value]
        if (ArgumentCount != 4)
        {
            Usage(Command);
        }
        else
        {
            //char *Option = Arguments[CurrentArgument++];
            //char *Value = Arguments[CurrentArgument++];
        }
    }
    else if (strcmp(Command, "add") == 0)
    {
        // add [parent?:]["summary"] [tags?]
        if (ArgumentCount < 4)
        {
            Usage(Command);
        }
        else
        {
            //char *Summary = Arguments[CurrentArgument++];

            // TODO(Oskar); Parse tags
            //char *Tags = 0;
        }

    }

    return 0;
}
