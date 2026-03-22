shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 color : source_color = vec4(0.6, 0.1, 0.9, 1.0);
uniform float glow_intensity : hint_range(0.0, 20.0) = 2.0;

void fragment() {
    ALBEDO = color.rgb;
    EMISSION = color.rgb * glow_intensity;
}
