shader_type canvas_item;

/*
Attach to GPUParticles2D or CPUParticles2D.
Use a soft white oval or gradient texture, additive blend, glow ON.
Enable “Align Y to Velocity” in process material.
*/

uniform float cursor_speed : hint_range(0.0, 1.0) = 0.0; // set from script

uniform float hue_shift_speed : hint_range(0.0, 5.0) = 1.0;
uniform float trail_hue_scale : hint_range(0.0, 0.01) = 0.002;
uniform float stretch_factor  : hint_range(1.0, 5.0) = 2.0;
uniform float fade_power      : hint_range(0.5, 4.0) = 2.0;
uniform float brightness      : hint_range(0.0, 2.0) = 1.2;
uniform float saturation      : hint_range(0.0, 1.0) = 1.0;

uniform float base_stretch = 1.5;
uniform float max_extra_stretch = 3.0;

void vertex() {
    // stretch along velocity direction (Align Y to Velocity must be enabled)
    float dynamic_stretch = base_stretch + cursor_speed * max_extra_stretch * 0.001;
	VERTEX.y *= dynamic_stretch;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // fade alpha toward tail
    tex.a *= pow(1.0 - UV.y, fade_power);

    // Compute a rainbow gradient that flows along screen-space
    float hue = mod(TIME * hue_shift_speed + SCREEN_UV.x * trail_hue_scale, 1.0);

    // HSV -> RGB
    float h6 = hue * 6.0;
    float c = brightness * saturation;
    float x = c * (1.0 - abs(mod(h6, 2.0) - 1.0));
    vec3 rgb;
    if (h6 < 1.0) rgb = vec3(c, x, 0.0);
    else if (h6 < 2.0) rgb = vec3(x, c, 0.0);
    else if (h6 < 3.0) rgb = vec3(0.0, c, x);
    else if (h6 < 4.0) rgb = vec3(0.0, x, c);
    else if (h6 < 5.0) rgb = vec3(x, 0.0, c);
    else rgb = vec3(c, 0.0, x);
    float m = brightness - c;
    rgb += vec3(m);

    COLOR = vec4(rgb, tex.a);
}
