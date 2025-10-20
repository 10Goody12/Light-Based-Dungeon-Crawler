shader_type canvas_item;
render_mode unshaded;

uniform float speed = 1.0;

// Converts HSV color to RGB
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	float hue = mod(TIME * speed + UV.x + UV.y, 1.0);
	vec3 rgb = hsv2rgb(vec3(hue, 1.0, tex_color.a));

	COLOR = vec4(rgb, tex_color.a);
}
