// Football jersey for a lathed torso mesh: block numbers front and back with an
// outline, side panels, and a subtle mesh-fabric texture.
// UV.x = around the body (0 = chest, 0.5 = back), UV.y = 0 at the waist, 1 at the collar.
shader_type spatial;
render_mode cull_disabled;

#include "res://shaders/noise.gdshaderinc"

uniform vec3 jersey_color : source_color = vec3(0.1, 0.2, 0.55);
uniform vec3 number_color : source_color = vec3(1.0);
uniform vec3 trim_color : source_color = vec3(0.95, 0.72, 0.15);
uniform int number = 0;

// Seven-segment masks: a=1 b=2 c=4 d=8 e=16 f=32 g=64.
int seg_mask(int d) {
	if (d == 0) { return 63; }
	if (d == 1) { return 6; }
	if (d == 2) { return 91; }
	if (d == 3) { return 79; }
	if (d == 4) { return 102; }
	if (d == 5) { return 109; }
	if (d == 6) { return 125; }
	if (d == 7) { return 7; }
	if (d == 8) { return 127; }
	return 111;
}

// Block digit in a 0..1 box. t = stroke thickness.
float digit(vec2 p, int d, float t) {
	if (p.x < 0.0 || p.x > 1.0 || p.y < 0.0 || p.y > 1.0) {
		return 0.0;
	}
	int m = seg_mask(d);
	bool upper = p.y >= 0.5;
	float s = 0.0;
	if ((m & 1) != 0 && p.y > 1.0 - t) { s = 1.0; }
	if ((m & 64) != 0 && abs(p.y - 0.5) < t * 0.5) { s = 1.0; }
	if ((m & 8) != 0 && p.y < t) { s = 1.0; }
	if ((m & 32) != 0 && p.x < t && upper) { s = 1.0; }
	if ((m & 2) != 0 && p.x > 1.0 - t && upper) { s = 1.0; }
	if ((m & 16) != 0 && p.x < t && !upper) { s = 1.0; }
	if ((m & 4) != 0 && p.x > 1.0 - t && !upper) { s = 1.0; }
	return s;
}

// q: 0..1 over the whole number block. pad grows the digits (for the outline).
float number_mask(vec2 q, float t, float pad) {
	int n = clamp(number, 0, 99);
	q = (q - 0.5) * (1.0 - pad * 2.0) + 0.5;
	if (n < 10) {
		return digit(vec2((q.x - 0.27) / 0.46, q.y), n, t);
	}
	float a = digit(vec2(q.x / 0.46, q.y), n / 10, t);
	float b = digit(vec2((q.x - 0.54) / 0.46, q.y), n % 10, t);
	return max(a, b);
}

void fragment() {
	float u = UV.x;
	float v = UV.y;
	vec3 col = jersey_color;

	// Side panels.
	float side = min(abs(u - 0.25), abs(u - 0.75));
	col = mix(col, trim_color, 1.0 - smoothstep(0.035, 0.045, side));

	// Numbers on chest and back. Viewer's left = increasing u on both sides.
	float d_front = fract(u + 0.5) - 0.5;
	float d_back = u - 0.5;
	float d = abs(d_front) < abs(d_back) ? d_front : d_back;
	vec2 q = vec2((-d + 0.15) / 0.3, (v - 0.1) / 0.42);
	float outline = number_mask(q, 0.32, 0.05);
	float fill = number_mask(q, 0.2, 0.0);
	col = mix(col, trim_color, outline);
	col = mix(col, number_color, fill);

	// Mesh fabric.
	float weave = vnoise(UV * vec2(260.0, 140.0));
	col *= 0.9 + 0.12 * weave;

	ALBEDO = col;
	ROUGHNESS = 0.75;
	SPECULAR = 0.3;
}
