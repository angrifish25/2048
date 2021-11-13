require daslib/media
require graphics
require daslib/random
require daslib/decs_boost
require helpers

[decs_template]
struct GameOver
    is_game_over: bool

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

def move_block_if_need(eid: EntityId const&#; new_pos: int2; value: int; is_merged: bool )
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
    elif !has_neibor
        eid |> update_entity <| @ ( eid, cmp )
            cmp |> set("pos", new_pos)

    if has_neibor && (neibor.value == value) && !neibor.is_merged && !is_merged
        neibor.id |> update_entity <| @ ( eid, cmp )
            cmp |> set("value", value + neibor.value)
            cmp |> set("is_merged", true)
        delete_entity(eid)

def find_new_pos()
    var new_pos = int2( get_random(0, 3), get_random(0, 3) )
    var founded = false
    query <| $ ( eid: EntityId; pos: int2; value: int)
        if(new_pos == pos)
            founded = true
    if (founded)
        return find_new_pos()
    return new_pos

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

def game_over()
    var availible_blocks: array<int2>
    query <| $ ( eid: EntityId; pos: int2; value: int)
        availible_blocks |> push(pos)
    return length(availible_blocks) == 16

def create_block()
    let is_game_over = game_over()
    if (is_game_over)
        create_entity <| @ ( eid, cmp )
            cmp |> set("eid", eid)
            apply_decs_template(cmp, [[GameOver]])
        return
    let find_pos = find_new_pos()
    let rand_value = random_float(seed) > .5 ? 4 : 2
    create_entity <| @ ( eid, cmp )
        cmp |> set("eid", eid)
        cmp |> set("pos", find_pos)
        cmp |> set("is_merged", false)
        cmp |> set("value", rand_value)

[decs(stage = draw_game_over)]
def draw_game_over(var game_over: GameOver)
    var start = int2()
    var size_field = 0
    query <| $ ( start_position : int2; size: int )
        start = start_position
        size_field = size

    fill_rect(start.x, start.y, size_field, size_field, 0xFFFFFF)
    text_out(start.x + (size_field/2), start.y + (size_field/2), "Game Over\n press Enter for restart", 0x000000)

[decs(stage = draw_blocks)]
def draw_blocks(var pos: int2;  value: int)
    var start = int2()
    var gap_field = 0
    var size = 0
    
    query <| $ ( start_position : int2; gap: int; block_size: int)
        start = start_position
        gap_field = gap
        size = block_size

    let pos_x = get_position(start.x, size, pos.x, gap_field)
    let pos_y = get_position(start.y, size, pos.y, gap_field)

    fill_rect(pos_x, pos_y, size, size, 0xFFFFFF)
    text_out(pos_x + (size/2), pos_y + (size/2), "{value}", 0x000000)

[decs(stage = update_blocks)]
def update_blocks( eid: EntityId; pos: int2; value: int; is_merged: bool; updating: Updating)
    query <| $ ( direction: int2 )
        move_block_if_need(eid, pos + direction, value, is_merged)

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
        commit()
    if get_key_press(VK_RETURN)
        query <| $ ( eid: EntityId; game_over: GameOver)
            query <| $ ( eid: EntityId; pos: int2; value: int)
                delete_entity(eid)
            delete_entity(eid)
            create_block()
            create_block()
            commit()