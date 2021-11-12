require daslib/media
require graphics
require helpers

def render_block( pos: int2; size: int; color: int )
    fill_rect(pos.x, pos.y, size, size, color)
