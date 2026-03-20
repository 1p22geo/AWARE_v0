shader_type canvas_item;

uniform float strength = 1.4;
uniform float speed = 2.0;
uniform float edge_start = 0.3;

uniform float vignette_intensity = 0.45;
uniform float vignette_start = 0.4;
uniform float vignette_end = 0.9;
uniform float vignette_distortion = 0.2;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Distance from center, normalized to [0, 1]
    float dist = distance(uv, vec2(0.5)) / length(vec2(0.5));

    // Mask: only affect edges
    float edge = smoothstep(edge_start, 1.0, dist);

    // Time-based glitch signals
    float t = TIME * speed;

    // Horizontal glitch waves
    float glitch_wave = sin(uv.y * 40.0 + t * 3.0) * 0.005;

    // Random-ish noise
    float noise = fract(sin(dot(uv * t, vec2(12.9898,78.233))) * 43758.5453);

    // Combine distortions
    float offset = (glitch_wave + (noise - 0.5) * 0.02) * edge * strength;

    // Apply horizontal distortion
    uv.x += offset;

    // Optional RGB split (chromatic aberration)
    vec4 col;
    col.r = texture(SCREEN_TEXTURE, uv + vec2(offset * 0.5, 0.0)).r;
    col.g = texture(SCREEN_TEXTURE, uv).g;
    col.b = texture(SCREEN_TEXTURE, uv - vec2(offset * 0.5, 0.0)).b;
    col.a = 1.0;

    // Distorted Vignette
    float distorted_dist = dist + (noise - 0.5) * vignette_distortion;
    float vignette = smoothstep(vignette_start, vignette_end, distorted_dist);
    col.rgb *= 1.0 - vignette * vignette_intensity;

    COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
