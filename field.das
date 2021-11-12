require daslib/media
require daslib/decs_boost
require structurs
require helpers

def create_field( start: int2; gap: int; field_size: int; block_size: int )
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("start_position", start)
        cmp |> set("block_size", block_size)
        cmp |> set("size", field_size)
        cmp |> set("gap", gap)

[decs(stage = draw)]
def draw_field(var start_position: int2; block_size: int; size: int; gap: int)
    fill_rect(start_position.x, start_position.y, size, size, 0xC59B76)
    for i in range(0, 4)
        for j in range(0, 4)
            fill_rect(get_position(start_position.x, block_size, i, gap), get_position(start_position.y, block_size, j, gap), block_size, block_size, 0xE1CBB7)
