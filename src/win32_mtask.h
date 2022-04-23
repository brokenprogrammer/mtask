struct tag
{
    char *Tag;
    tag *Next;
};

enum task_state
{
    TaskState_Pending,
    TaskState_Active,
    TaskState_Paused,
    TaskState_Blocked,
    TaskState_Completed
};

// TODO(Oskar): Replace linked lists
struct task
{
    uint64_t ID;
    char *Summary;

    task_state State;
    // Started
    double TimeSpent;

    tag *Tags;
    
    task *Parent;
    task *Children;
};

enum sync_integration
{
    None,
    DevOps,
    Github
};
struct workspace
{
    char *Name;

    sync_integration SyncIntegration;
    
    task *FirstTask;
};

struct mtask_config
{
    bool Loaded;
    
    uint32_t ActiveWorkspaceNameLength;
    char *ActiveWorkspaceName;
};
