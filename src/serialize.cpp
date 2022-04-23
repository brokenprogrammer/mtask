static void
Serialize(lbp_serializer *LBPSerializer, uint32_t *Datum)
{
    if (LBPSerializer->IsWriting)
    {
        fwrite(Datum, sizeof(uint32_t), 1, LBPSerializer->FilePointer);
    }
    else
    {
        fread(Datum, sizeof(uint32_t), 1, LBPSerializer->FilePointer);
    }
}

static void
Serialize(lbp_serializer *LBPSerializer, uint64_t *Datum)
{
    if (LBPSerializer->IsWriting)
    {
        fwrite(Datum, sizeof(uint64_t), 1, LBPSerializer->FilePointer);
    }
    else
    {
        fread(Datum, sizeof(uint64_t), 1, LBPSerializer->FilePointer);
    }
}

static void
Serialize(lbp_serializer *LBPSerializer, double *Datum)
{
    if (LBPSerializer->IsWriting)
    {
        fwrite(Datum, sizeof(double), 1, LBPSerializer->FilePointer);
    }
    else
    {
        fread(Datum, sizeof(double), 1, LBPSerializer->FilePointer);
    }
}


static void
Serialize(lbp_serializer *LBPSerializer, char **Datum, uint32_t DatumLength)
{
    if (LBPSerializer->IsWriting)
    {
        fwrite(*Datum, sizeof(char) * DatumLength, 1, LBPSerializer->FilePointer);
    }
    else
    {
        *Datum = (char *)malloc(sizeof(char) * DatumLength);
        fread(*Datum, sizeof(char) * DatumLength, 1, LBPSerializer->FilePointer);
        (*Datum)[DatumLength] = 0;
    }
}

static void
Serialize(lbp_serializer *LBPSerializer, tag *Datum)
{
    ADD(SV_Initial, NameLength);
    ADD_LIST(SV_Initial, Name, NameLength);
}

static void
Serialize(lbp_serializer *LBPSerializer, tag **Datum, uint32_t DatumLength)
{
    if (!LBPSerializer->IsWriting)
    {
        *Datum = (tag *)calloc(DatumLength, sizeof(task));
    }

    for (uint32_t Index = 0; Index < DatumLength; ++Index)
    {
        Serialize(LBPSerializer, Datum[Index]);
    }
}

static void
Serialize(lbp_serializer *LBPSerializer, task_state *Datum)
{
    Serialize(LBPSerializer, (uint32_t *)Datum);
}

static void
Serialize(lbp_serializer *LBPSerializer, task **Datum, uint32_t DatumLength);

static void
Serialize(lbp_serializer *LBPSerializer, task *Datum)
{
    ADD(SV_Initial, ID);

    ADD(SV_Initial, SummaryLength);
    ADD_LIST(SV_Initial, Summary, SummaryLength);

    ADD(SV_Initial, State);
    ADD(SV_Initial, TimeSpent);

    ADD(SV_Initial, NumberOfTags);
    ADD_LIST(SV_Initial, Tags, NumberOfTags);

    ADD_REF(SV_Initial, Parent);

    ADD(SV_Initial, NumberOfChildren);
    ADD_LIST(SV_Initial, Children, NumberOfChildren);
}

static void
Serialize(lbp_serializer *LBPSerializer, task **Datum, uint32_t DatumLength)
{
    if (!LBPSerializer->IsWriting)
    {
        *Datum = (task *)calloc(DatumLength, sizeof(task));
    }

    for (uint32_t Index = 0; Index < DatumLength; ++Index)
    {
        Serialize(LBPSerializer, (*Datum) + Index);
    }
}

static void
Serialize(lbp_serializer *LBPSerializer, sync_integration *Datum)
{
    Serialize(LBPSerializer, (uint32_t *)Datum);
}

static void
Serialize(lbp_serializer *LBPSerializer, workspace *Datum)
{
    ADD(SV_Initial, NameLength);
    ADD_LIST(SV_Initial, Name, NameLength);

    ADD(SV_Initial, SyncIntegration);
    
    ADD(SV_Initial, NumberOfTasks);
    ADD_LIST(SV_Initial, Tasks, NumberOfTasks);
}

static bool
SerializeIncludingVersion(lbp_serializer *LBPSerializer, workspace *Workspace)
{
    if (LBPSerializer->IsWriting)
    {
        LBPSerializer->DataVersion = LATEST_VERSION;
    }

    Serialize(LBPSerializer, &LBPSerializer->DataVersion);

    // NOTE(Oskar): Reading file from a version that came after this one
    if (LBPSerializer->DataVersion > (LATEST_VERSION))
    {
        return false;
    }
    else
    {
        Serialize(LBPSerializer, Workspace);
        return true;
    }
}


static void
Serialize(lbp_serializer *LBPSerializer, mtask_config *Datum)
{
    //Serialize(LBPSerializer, &Datum->ActiveWorkspaceNameLength);
    ADD(SV_Initial, ActiveWorkspaceNameLength);

    //Serialize(LBPSerializer, Datum->ActiveWorkspaceName, Datum->ActiveWorkspaceNameLength);
    ADD_LIST(SV_Initial, ActiveWorkspaceName, ActiveWorkspaceNameLength);
}

static bool
SerializeIncludingVersion(lbp_serializer *LBPSerializer, mtask_config *Config)
{
    if (LBPSerializer->IsWriting)
    {
        LBPSerializer->DataVersion = LATEST_VERSION;
    }

    Serialize(LBPSerializer, &LBPSerializer->DataVersion);

    // NOTE(Oskar): Reading file from a version that came after this one
    if (LBPSerializer->DataVersion > (LATEST_VERSION))
    {
        return false;
    }
    else
    {
        Serialize(LBPSerializer, Config);
        return true;
    }
}
