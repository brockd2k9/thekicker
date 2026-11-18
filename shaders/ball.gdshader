// Leather football: pebbled grain, panel seams, worn tips, optional white stripes.
// Expects UV.x = around the ball (0..1), UV.y = along the long axis (0..1).
shader_type spatial;
render_mode cull_disabled;

#include "res://shaders/noise.gdshaderinc"

uniform vec3 leather : source_color = vec3(0.50, 0.22, 0.09);
uniform vec3 leather_dark : source_color = vec3(0.27, 0.11, 0.04);
uniform vec3 stripe_color : source_color = vec3(0.96, 0.94, 0.88);
uniform bool stripes = true;
uniform float ball_length = 0.28;
uniform float ball_radius = 0.085;

void fragment() {
	float u = UV.x;
	float v = UV.y;
	vec2 sp = vec2(u * 6.2832 * ball_radius, v * ball_length); // ~meters on the surface
	float pebble = vnoise(sp * 300.0);
	float mottle = vnoise(sp * 45.0);
	vec3 col = mix(leather_dark, leather, 0.55 + 0.45 * mottle);
	col *= 0.85 + 0.25 * pebble;

	float tip = abs(v - 0.5) * 2.0;
	col *= 1.0 - 0.35 * smoothstep(0.6, 1.0, tip);

	// Four panel seams along the long axis (u = 0, .25, .5, .75). Laces sit on .25.
	float seam_d = abs(fract(u * 4.0 + 0.5) - 0.5);
	float sw = fwidth(seam_d) + 0.001;
	float seam = 1.0 - smoothstep(0.006, 0.006 + sw, seam_d);
	col = mix(col, leather_dark * 0.45, seam);

	if (stripes) {
		float sd = min(abs(v - 0.2), abs(v - 0.8));
		float s = 1.0 - smoothstep(0.022, 0.022 + fwidth(v) + 0.001, sd);
		col = mix(col, stripe_color * (0.92 + 0.08 * pebble), s * (1.0 - seam));
	}

	ALBEDO = col;
	ROUGHNESS = 0.5 - 0.15 * pebble;
	SPECULAR = 0.45;
}
