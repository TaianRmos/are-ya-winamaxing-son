shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 rect_size = vec2(1.0, 1.0);

varying vec2 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    // normalize to 0..1 within the control's rect
    vec2 norm = local_pos / rect_size;
    // 0 at bottom-left, 2 at top-right (y flipped: local (0,0) is top-left in Control space)
    float diag = norm.x + (1.0 - norm.y);
    if (diag > progress * 2.0) {
        discard;
    }
}