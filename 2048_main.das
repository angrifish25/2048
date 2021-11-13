require daslib/media
require daslib/decs_boost

require field
require blocks

let 
    screen_width = get_screen_width()
    screen_height = get_screen_height()

var 
    start_pos = int2(100, 100)
    gap = 20
    field_size = 400
    block_size = 75

[export]
def initialize
    set_window_title("2048")
    restart()
    create_field(start_pos, gap, field_size, block_size)
    create_block()
    create_block()
    create_direction()
    commit()

[export]
def act()
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    decs_stage("update_controls")    
    decs_stage("update_blocks")
    decs_stage("merge_blocks")
    decs_stage("add_new_block")
    decs_stage("game_over")

[export]
def draw
    fill_rect(0, 0, screen_width, screen_height, 0xFFFFFF)
    decs_stage("draw")
    decs_stage("draw_blocks")
    decs_stage("draw_best_score")
    decs_stage("draw_game_over")
    
options debugger
require daslib/debug