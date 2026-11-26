shader_type spatial;
render_mode diffuse_burley;

// Original, texture-free facade finish: low-contrast plaster grain and a
// restrained, world-aligned window cadence. Existing authored mullions and
// glazing remain the readable foreground detail.
uniform vec4 facade_tint : source_color = vec4(0.48, 0.46, 0.41, 1.0);
uniform float facade_seed = 0.0;
uniform float window_strength = 1.0;
varying vec3 world_position;
varying vec3 world_normal;

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
    bool x_facing = abs(world_normal.x) > abs(world_normal.z);
    vec2 face_position = x_facing ? world_position.zy : world_position.xy;
    vec2 cell = floor(face_position / vec2(3.05, 2.35));
    vec2 panel_uv = fract(face_position / vec2(3.05, 2.35));
    float window_shape = step(0.16, panel_uv.x) * step(panel_uv.x, 0.84)
        * step(0.27, panel_uv.y) * step(panel_uv.y, 0.79);
    float vertical_surface = 1.0 - step(0.45, abs(world_normal.y));
    float above_shopfront = smoothstep(0.55, 1.05, world_position.y);
    float window = window_shape * vertical_surface * above_shopfront * window_strength;
    vec2 grain_position = face_position * 1.35 + vec2(facade_seed * 0.013);
    vec2 grain_cell = floor(grain_position);
    vec2 grain_uv = fract(grain_position);
    grain_uv = grain_uv * grain_uv * (3.0 - 2.0 * grain_uv);
    float grain_a = mix(hash21(grain_cell), hash21(grain_cell + vec2(1.0, 0.0)), grain_uv.x);
    float grain_b = mix(hash21(grain_cell + vec2(0.0, 1.0)), hash21(grain_cell + vec2(1.0, 1.0)), grain_uv.x);
    float variation = mix(grain_a, grain_b, grain_uv.y);
    float plaster = 0.90 + variation * 0.18;
    vec3 wall = facade_tint.rgb * plaster;
    float glass_variation = hash21(cell + vec2(facade_seed, 4.7));
    vec3 glass = mix(vec3(0.095, 0.19, 0.22), vec3(0.22, 0.34, 0.34), glass_variation);
    // A faintly warmer subset suggests occupied rooms, not luminous billboards.
    float occupied = step(0.88, glass_variation) * 0.10;
    glass = mix(glass, vec3(0.43, 0.32, 0.20), occupied);
    ALBEDO = mix(wall, glass, window * 0.72);
    ROUGHNESS = mix(0.83, 0.42, window);
    METALLIC = 0.0;
}
