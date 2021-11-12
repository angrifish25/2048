require daslib/media
require graphics
require daslib/random
require daslib/decs_boost
require helpers

[decs_template]
struct GameOver
    is_gameover: bool
[decs_template]
struct Updating
    is_merged: bool
[decs_template]
struct Merge
    eid_merge: EntityId
    value: int

var 
    seed = random_seed(int(get_time_after_start()))

def create_direction()
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("direction", int2())

def get_random(min: int; max: int)
    return int(random_float(seed) * float((max - min + 1) + min))

def move_block_if_need(eid: EntityId const&#; old_pos: int2; new_pos: int2; value: int; is_merged: bool )
    var has_neibor = false
    var neibor: tuple<id: EntityId; pos: int2; value: int; is_merged: bool>
    query <| $ ( eid: EntityId; pos: int2; value: int; is_merged: bool)
        if (new_pos == pos)
            has_neibor = true
            neibor.id := eid
            neibor.pos = pos
            neibor.value = value
            neibor.is_merged = is_merged

    if !inField(new_pos)
        eid |> update_entity <| @ ( eid, cmp )
            remove_decs_template`Updating(cmp)
            
    if inField(new_pos) && !has_neibor
        eid |> update_entity <| @ ( eid, cmp )
            cmp |> set("pos", new_pos)

    if has_neibor && (neibor.value == value) && !neibor.is_merged && !is_merged
        neibor.id |> update_entity <| @ ( eid, cmp )
            cmp |> set("value", value + neibor.value)
            cmp |> set("is_merged", true)
        delete_entity(eid)
var count_attempt = 0

def find_new_pos()
    count_attempt += 1
    var new_pos = int2( get_random(0, 3), get_random(0, 3) )
    var founded = false
    query <| $ ( eid: EntityId; pos: int2; value: int)
        if(new_pos == pos)
            founded = true
    if (count_attempt == 16)
        return int2(-1,-1)
    if (founded)
        return find_new_pos()
    count_attempt = 0
    return new_pos
let game_over_const = int2(-1,-1)

def create_block()
    var find_pos = find_new_pos()
    if (find_pos == game_over_const)
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            apply_decs_template(cmp, [[GameOver]])
            
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("pos", find_pos)
        cmp |> set("is_merged", false)
        cmp |> set("value", get_random(2, 4))

[decs(stage = draw_blocks)]
def draw_blocks(var pos: int2;  value: int)
    var start = int2()
    var gap_field = 0
    query <| $ ( start_position : int2; gap: int )
        start = start_position
        gap_field = gap

    let pos_x = get_position(start.x, 75, pos.x, gap_field)
    let pos_y = get_position(start.y, 75, pos.y, gap_field)

    fill_rect(pos_x, pos_y, 75, 75, 0xFFFFFF)
    text_out(pos_x + (75/2), pos_y + (75/2), "{value}", 0x000000)
    
// [decs(stage = game_over)]
// def game_over( eid_a: EntityId; game_over: GameOver)
//     query <| $ ( eid, pos )
//         delete_entity(eid)

[decs(stage = update_blocks)]
def update_blocks( eid: EntityId; pos: int2; value: int; is_merged: bool; updating: Updating)
    query <| $ ( direction: int2 )
        move_block_if_need(eid, pos, pos + direction, value, is_merged)

def get_direction()
    if get_key_down(VK_LEFT)
        return int2( -1, 0)
    if get_key_down(VK_RIGHT)
        return int2( 1, 0)
    if get_key_down(VK_UP)
        return int2( 0, -1)
    if get_key_down(VK_DOWN)
        return int2( 0, 1)
    return int2()

[decs(stage = update_controls)]
def update_controls(eid: EntityId; var direction: int2 )
    if get_key_down(VK_LEFT) || get_key_down(VK_RIGHT) || get_key_down(VK_UP) || get_key_down(VK_DOWN)
        eid |> update_entity <| @ ( eid, cmp )
            cmp |> set("direction", get_direction())
        query <| $ ( eid: EntityId; pos: int2; value: int)
            eid |> update_entity <| @ ( eid, cmp )
                cmp |> set("is_merged", false)
                apply_decs_template(cmp, [[Updating]])
    if get_key_up(VK_LEFT) || get_key_up(VK_RIGHT) || get_key_up(VK_UP) || get_key_up(VK_DOWN)
        create_block()