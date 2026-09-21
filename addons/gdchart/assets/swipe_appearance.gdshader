shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 rect_size = vec2(1.0, 1.0);

varying vec2 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    float norm_x = local_pos.x / rect_size.x;
    if (norm_x > progress) {
        discard;
    }
}