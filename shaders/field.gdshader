// Procedural football field: mowing stripes, grass grain, yard lines, hash marks,
// end zone. Everything is computed from world position, so it needs no textures.
shader_type spatial;

#include "res://shaders/noise.gdshaderinc"

uniform float goal_z = -36.0; // world Z of the end line (where the posts stand)
uniform vec3 grass_light : source_color = vec3(0.26, 0.56, 0.22);
uniform vec3 grass_dark : source_color = vec3(0.19, 0.46, 0.17);
uniform vec3 endzone_color : source_color = vec3(0.09, 0.18, 0.46);
uniform vec3 line_color : source_color = vec3(0.96, 0.96, 0.93);
uniform vec3 outside_color : source_color = vec3(0.15, 0.34, 0.15);
uniform float field_half_width = 24.38;
uniform float grain_strength = 0.4;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// 1 inside a line of half-width hw around dist = 0, antialiased.
float line_mask(float dist, float hw) {
	float w = fwidth(dist) + 0.0001;
	return 1.0 - smoothstep(hw - w, hw + w, dist);
}

void fragment() {
	vec2 p = world_pos.xz;
	float yd = (p.y - goal_z) / 0.9144; // yards from the end line toward the kicker
	float ax = abs(p.x);

	float band = floor((yd - 10.0) / 5.0);
	vec3 col = mod(band, 2.0) < 1.0 ? grass_light : grass_dark;
	if (yd < 10.0) {
		col = endzone_color * (0.92 + 0.08 * step(0.5, fract((p.x + p.y) * 0.25)));
	}
	if (ax > field_half_width || yd < 0.0) {
		col = outside_color;
	}

	// Grass grain: blade streaks + clumps + big patches, fading out with distance
	// so it never shimmers.
	float fw = length(fwidth(p));
	float fine_fade = clamp(1.0 - fw * 8.0, 0.0, 1.0);
	float mid_fade = clamp(1.0 - fw * 1.5, 0.0, 1.0);
	float blades = vnoise(vec2(p.x * 45.0, p.y * 7.0));
	float clumps = vnoise(p * 3.5);
	float patches = vnoise(p * 0.11);
	col *= 1.0 + grain_strength * ((blades - 0.5) * fine_fade + (clumps - 0.5) * 0.6 * mid_fade)
		+ (patches - 0.5) * 0.2;

	float lines = 0.0;
	if (ax <= field_half_width + 0.1 && yd >= -0.1) {
		float zy = (yd - 10.0) / 5.0;
		float d5 = abs(zy - round(zy)) * 5.0 * 0.9144;
		float hw = abs(yd - 10.0) < 1.0 ? 0.1 : 0.05; // goal line is wider
		if (yd >= 9.9) {
			lines = max(lines, line_mask(d5, hw));
		}
		lines = max(lines, line_mask(abs(p.y - goal_z), 0.06));
		// Hash marks every yard, in line with the uprights.
		float d1 = abs(yd - round(yd)) * 0.9144;
		float on_hash = step(abs(ax - 3.12), 0.3);
		if (yd > 10.0) {
			lines = max(lines, line_mask(d1, 0.05) * on_hash);
		}
	}
	lines = max(lines, line_mask(abs(ax - field_half_width), 0.1) * step(-0.1, yd));
	// Painted lines take a little grain too.
	col = mix(col, line_color * (0.9 + 0.1 * clumps), lines);

	ALBEDO = col;
	ROUGHNESS = 0.92;
	SPECULAR = 0.25;
}
