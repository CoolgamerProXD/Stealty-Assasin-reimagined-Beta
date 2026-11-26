shader_type spatial;
render_mode diffuse_burley;

// Original low-frequency sidewalk wear and 3 m slab joints in world space.
uniform vec4 paving_tint : source_color = vec4(0.34, 0.36, 0.35, 1.0);
varying vec2 world_xz;

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
    world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
    vec2 slab_uv = fract(world_xz / 3.0);
    float joint = max(step(slab_uv.x, 0.012), step(slab_uv.y, 0.012));
    vec2 cell = floor(world_xz / 3.0);
    float mottling = hash21(cell) * 0.055 + hash21(floor(world_xz * 5.0)) * 0.018;
    float worn_edge = smoothstep(0.02, 0.17, min(min(slab_uv.x, 1.0-slab_uv.x), min(slab_uv.y, 1.0-slab_uv.y)));
    vec3 color = paving_tint.rgb * (0.96 + mottling) * (0.97 + worn_edge * 0.03);
    ALBEDO = mix(color, color * 0.67, joint);
    ROUGHNESS = 0.94;
}
