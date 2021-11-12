require daslib/media
require daslib/decs_boost

require field
require blocks

let 
    screen_width = get_screen_width()
    screen_height = get_screen_height()

var 
    start_pos = int2(100, 100)
    block_size = 75
    gap = 20

[export]
def initialize
    restart()
    create_field(start_pos, gap, 400, block_size)
    create_block()
    create_block()
    commit()
    create_direction()
    set_window_title("2048")

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    decs_stage("update_controls")    
    decs_stage("update_blocks")
    decs_stage("merge_blocks")
    decs_stage("add_new_block")
    decs_stage("game_over")
    return

[export]
def draw
    fill_rect(0, 0, screen_width, screen_height, 0xFFFFFF)
    decs_stage("draw")
    decs_stage("draw_blocks")
    
    return

options debugger
require daslib/debug