require daslib/decs_boost

[decs_template]
struct Updating
    is_merged: bool
[decs_template]
struct Merge
    eid_merge: EntityId
    value: int