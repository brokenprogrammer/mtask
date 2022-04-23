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
Serialize(lbp_serializer *LBPSerializer, mtask_config *Datum)
{
    //Serialize(LBPSerializer, &Datum->ActiveWorkspaceNameLength);
    ADD(SV_Initial, ActiveWorkspaceNameLength);

    //Serialize(LBPSerializer, Datum->ActiveWorkspaceName, Datum->ActiveWorkspaceNameLength);
    ADD_STRING(SV_Initial, ActiveWorkspaceName, ActiveWorkspaceNameLength);
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
