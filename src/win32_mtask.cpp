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

static void
CreateWorkspace(mtask_config *Config)
{
//    char WorkspaceFileName[512];
//    sprintf(WorkspaceFileName, "%s.mtask", WorkspaceName);
            
    FILE *WorkSpaceFilePointer;
    if (WorkSpaceFilePointer = fopen(Config->ActiveWorkspacePath, "w"))
    {
        workspace Workspace = {0};
        Workspace.Name = Config->ActiveWorkspacePath;
        Workspace.NameLength = Config->ActiveWorkspacePathLength;
        Workspace.NumberOfTasks = 0;

        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = true;
        LBPSerializer.FilePointer = WorkSpaceFilePointer;

        SerializeIncludingVersion(&LBPSerializer, &Workspace);
        fclose(WorkSpaceFilePointer);
    }
}

static workspace
LoadWorkspace(mtask_config *Config)
{
    workspace Workspace = {0};
    
    FILE *WorkSpaceFilePointer;
    if (WorkSpaceFilePointer = fopen(Config->ActiveWorkspacePath, "r"))
    {
        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = false;
        LBPSerializer.FilePointer = WorkSpaceFilePointer;
        SerializeIncludingVersion(&LBPSerializer, &Workspace);
        fclose(WorkSpaceFilePointer);
    }

    return Workspace;
}

static void
SaveWorkspace(workspace *Workspace)
{
    FILE *FilePointer;
    if (FilePointer = fopen(Workspace->Name, "w+"))
    {
        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = true;
        LBPSerializer.FilePointer = FilePointer;
        SerializeIncludingVersion(&LBPSerializer, Workspace);
        fclose(FilePointer);
    }
}

static mtask_config
CreateConfiguration()
{
    mtask_config Config = {0};

    char *WorkspaceName = (char *)malloc(sizeof(char) * 512);
    printf("Enter a name for your workspace: ");
    scanf("%s", WorkspaceName);

    // NOTE(Oskar): Create file
    FILE *FilePointer;
    if (FilePointer = fopen("mtask.conf", "w"))
    {
        Config.ActiveWorkspacePath = WorkspaceName;
        Config.ActiveWorkspacePathLength = (uint32_t)strlen(WorkspaceName);
        Config.Loaded = true;
            
        lbp_serializer LBPSerializer = {0};
        LBPSerializer.IsWriting = true;
        LBPSerializer.FilePointer = FilePointer;
        if (SerializeIncludingVersion(&LBPSerializer, &Config))
        {
            printf("Successfully created a new configuration file!\n");

            // NOTE(Oskar): Now we create the workspace
            CreateWorkspace(&Config);
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

static void
AddTask(workspace *Workspace, char *Summary)
{
    Workspace->NumberOfTasks++;
    Workspace->Tasks = (task *)realloc(Workspace->Tasks, sizeof(task) * Workspace->NumberOfTasks);
    task *Task = &Workspace->Tasks[Workspace->NumberOfTasks - 1];

    Task->ID = Workspace->NumberOfTasks;

    Task->Summary = Summary;
    Task->SummaryLength = (uint32_t)strlen(Summary);

    Task->State = TaskState_Pending;
    Task->TimeSpent = 0.0;

    Task->NumberOfTags = 0;
    Task->Parent = 0;
    Task->NumberOfChildren = 0;    
}

static void
ListTasks(workspace *Workspace, char *ID = 0)
{
    if (ID)
    {
        // NOTE(Oskar): List all  task children
    }
    else
    {
        // NOTE(Oskar): List all tasks
        printf("%-10s%-25s\n", "ID", "Name");
        for(uint32_t Index = 0; Index < Workspace->NumberOfTasks; ++Index)
        {
            printf("%-10d%-25s\n", Workspace->Tasks[Index].ID, Workspace->Tasks[Index].Summary);
        }
    }
}

int main(int ArgumentCount, char **Arguments)
{
    if (ArgumentCount < 2)
    {
        Usage();
    }

    // NOTE(Oskar): Load configuration
    mtask_config Configuration = LoadConfiguration();
    workspace Workspace = LoadWorkspace(&Configuration);

    // TODO(Oskar): Verify that config and workspace is loaded correctly.
    
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
        if (ArgumentCount < 3)
        {
            Usage(Command);
        }
        else
        {
            char *Summary = Arguments[CurrentArgument++];
            AddTask(&Workspace, Summary);
            SaveWorkspace(&Workspace);
            
            // TODO(Oskar); Parse tags
            //char *Tags = 0;
        }
    }
    else if (strcmp(Command, "list") == 0)
    {
        // list [id?]
        if (ArgumentCount > 2)
        {
            //char *ID = Arguments[CurrentArgument++];
        }
        else
        {
            ListTasks(&Workspace);
        }
    }

    return 0;
}
