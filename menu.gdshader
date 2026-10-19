shader_type canvas_item;

uniform sampler2D text_texture;

void fragment() {
    vec4 tex_color = texture(text_texture, UV);
    vec4 text_color = texture(TEXTURE, UV);

    COLOR = vec4(tex_color.rgb, text_color.a);
}
