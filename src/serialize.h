struct lbp_serializer
{
    uint32_t DataVersion;
    FILE *FilePointer;
    bool IsWriting;
    uint32_t Counter;
};

enum serialization_versions : int32_t
{
    SV_Initial = 1,


    // Keep this as the last element
    SV_LatestPlusOne,
};

#define LATEST_VERSION (SV_LatestPlusOne - 1)

#define ADD(_fieldAdded, _fieldName) \
    if (LBPSerializer->DataVersion >= (_fieldAdded)) \
    { \
        Serialize(LBPSerializer, &(Datum->_fieldName)); \
    }

#define ADD_LIST(_fieldAdded, _fieldName, _fieldLength) \
    if (LBPSerializer->DataVersion >= (_fieldAdded)) \
    { \
    Serialize(LBPSerializer, &(Datum->_fieldName), (Datum->_fieldLength)); \
    }

#define ADD_REF(_fieldAdded, _fieldName) \
    if (LBPSerializer->DataVersion >= (_fieldAdded) && (Datum->_fieldName)) \
    { \
        Serialize(LBPSerializer, &(Datum->_fieldName), (1));    \
    }

#define REM(_fieldAdded, _fieldRemoved, _type, _fieldName, _defaultValue) \
    _type _fieldName = (_defaultValue); \
    if (LbpSerializer->DataVersion >= (_fieldAdded) && LbpSerializer->DataVersion < (_fieldRemoved)) \
    { \
        Serialize(LbpSerializer, &(_fieldName)); \
    }

#define CHECK_INTEGRITY(_checkAdded) \
    if (LbpSerializer->DataVersion >= (_checkAdded)) \
    { \
        int32_t Check = LbpSerializer->Counter; \
        Serialize(LbpSerializer, &Check); \
        ASSERT(Check == LbpSerializer->Counter++) \
    }
