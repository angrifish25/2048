def get_position(start_pos: int; block_size: int; index: int = 0; gap: int = 0 )
    return (start_pos + gap) + gap*index + (block_size * index)

def isSameBlock(pos_a: int2; pos_b: int2)
    return ((pos_a.x == pos_b.x) && pos_a.y == pos_b.y)

def inField(pos)
    return (pos.x >= 0 && pos.x < 4) && (pos.y >= 0 && pos.y < 4)