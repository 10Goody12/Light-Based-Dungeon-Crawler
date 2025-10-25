shader_type canvas_item;
render_mode blend_premul_alpha;

uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_angle : hint_range(0.0, 180.0, 0.1) = 45.0;
uniform float shine_speed : hint_range(0.01, 10.0, 0.01) = 0.3;
uniform float shine_delay : hint_range(0.0, 5.0, 0.1) = 0.0;
uniform bool shine_reverse = false;

uniform float Line_Width : hint_range(0.0, 0.2) = 0.09;
uniform float Line_Smoothness : hint_range(0.001, 0.1) = 0.045;
uniform float Brightness : hint_range(0.0, 10.0) = 3.0;
uniform float Distortion : hint_range(1.0, 3.0) = 2.0;
uniform float LensStrength : hint_range(0.0, 0.1) = 0.05;

// *Important*: we add this uniform to capture the node’s modulate color
uniform vec4 node_modulate : source_color = vec4(1.0);

void fragment() {
    vec2 uv = UV;

    // Direction & normal
    float angle_rad = radians(shine_angle);
    vec2 shine_dir = normalize(vec2(cos(angle_rad), -sin(angle_rad)));
    vec2 shine_normal = vec2(-shine_dir.y, shine_dir.x);

    // Radial gradient
    vec2 center_uv = uv - vec2(0.5);
    float gradient_to_edge = max(abs(center_uv.x), abs(center_uv.y));
    gradient_to_edge = 1.0 - gradient_to_edge * Distortion;
    gradient_to_edge = clamp(gradient_to_edge, 0.0, 1.0);

    // Animation
    float cycle_duration = (1.0 / shine_speed) + shine_delay;
    float time_in_cycle = mod(TIME, cycle_duration);
    float shine_progress = clamp(time_in_cycle * shine_speed, 0.0, 1.0);
    if (shine_reverse) {
        shine_progress = 1.0 - shine_progress;
    }

    float max_offset = 1.5;
    float offset = mix(-max_offset, max_offset, shine_progress);
    vec2 shine_origin = vec2(0.5) + shine_normal * offset;

    // Shine band
    float distance = dot(uv - shine_origin, shine_normal);
    float smoothness = clamp(Line_Smoothness, 0.001, 1.0);
    float half_width = Line_Width * 0.5;
    float shine_band = smoothstep(-half_width - smoothness, -half_width, distance) -
                      smoothstep(half_width, half_width + smoothness, distance);

    // Lens distortion
    vec2 lens_offset = shine_band * LensStrength * shine_normal;
    vec4 tex_color = texture(TEXTURE, uv + lens_offset);

    if (tex_color.a <= 0.0) {
        discard;
    }

    // Incorporate the node’s modulate
    tex_color.rgb *= node_modulate.rgb;
    tex_color.a *= node_modulate.a;

    // Compute intensity
    float final_intensity = shine_band * gradient_to_edge * Brightness;
    final_intensity = clamp(final_intensity, 0.0, 1.0);

    // Additive shine on top of the texture (tinted by node_modulate)
    vec3 color_with_shine = tex_color.rgb + shine_color.rgb * final_intensity;

    // Clamp (avoid over-bright) if you like
    color_with_shine = clamp(color_with_shine, vec3(0.0), vec3(1.0));

    COLOR = vec4(color_with_shine, tex_color.a);
}
