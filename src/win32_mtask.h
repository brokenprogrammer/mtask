struct tag
{
    uint32_t NameLength;
    char *Name;
};

enum task_state : uint32_t
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
    uint32_t ID;

    uint32_t SummaryLength;
    char *Summary;

    task_state State;
    double TimeSpent;

    uint32_t NumberOfTags;
    tag *Tags;
    
    task *Parent;

    uint32_t NumberOfChildren;
    task *Children;
};

enum sync_integration : uint32_t
{
    None,
    DevOps,
    Github
};
struct workspace
{
    uint32_t NameLength;
    char *Name;

    sync_integration SyncIntegration;

    uint32_t NumberOfTasks;
    task *Tasks;
};

struct mtask_config
{
    bool Loaded;
    
    uint32_t ActiveWorkspaceNameLength;
    char *ActiveWorkspaceName;
};
