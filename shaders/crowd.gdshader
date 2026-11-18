// Stadium seating full of fans, drawn per seat cell. Far away it blends to an
// average color so it doesn't sparkle. Use on a PlaneMesh; set plane_size to its size.
shader_type spatial;

#include "res://shaders/noise.gdshaderinc"

uniform vec2 plane_size = vec2(180.0, 45.0);
uniform vec2 seat_size = vec2(0.55, 0.85);
uniform vec3 home_color : source_color = vec3(0.10, 0.24, 0.62);
uniform vec3 alt_color : source_color = vec3(0.95, 0.55, 0.10);
uniform vec3 seat_color : source_color = vec3(0.20, 0.21, 0.25);
uniform vec3 concrete : source_color = vec3(0.42, 0.42, 0.45);
uniform float aisle_every = 26.0;
uniform float empty_seats = 0.08;
uniform float sway = 1.0;

vec3 shirt(float h, float h2) {
	if (h < 0.42) {
		return home_color * (0.8 + 0.4 * h2);
	}
	if (h < 0.58) {
		return alt_color * (0.8 + 0.4 * h2);
	}
	if (h < 0.72) {
		return vec3(0.88) * (0.85 + 0.15 * h2);
	}
	if (h < 0.82) {
		return vec3(0.1);
	}
	return vec3(h2, fract(h2 * 7.31), fract(h2 * 13.17)) * 0.75 + 0.1;
}

void fragment() {
	vec2 m = vec2(UV.x, 1.0 - UV.y) * plane_size; // y = up the stand
	vec2 g = m / seat_size;
	vec2 cell = floor(g);
	vec2 f = fract(g);
	float h = hash12(cell);
	float h2 = hash12(cell + 17.3);
	vec3 skin = mix(vec3(0.93, 0.74, 0.58), vec3(0.32, 0.2, 0.13), hash12(cell + 5.1));
	vec3 top = shirt(h, h2);

	float bob = sin(TIME * 2.5 + h * 6.28) * 0.04 * sway;
	float body = step(abs(f.x - 0.5), 0.33) * step(f.y, 0.55 + bob) * step(0.08, f.y);
	float head = step(length((f - vec2(0.5, 0.72 + bob)) * vec2(1.0, 1.25)), 0.17);
	vec3 person = mix(seat_color, top, body);
	person = mix(person, skin, head);
	float empty = step(1.0 - empty_seats, hash12(cell + 9.7));
	person = mix(person, seat_color, empty);
	person *= 0.7 + 0.3 * f.y; // row shadow

	vec3 avg = mix(seat_color, top, 0.55 * (1.0 - empty)) * 0.85;
	float px = length(fwidth(g));
	vec3 col = mix(person, avg, clamp((px - 0.2) * 2.5, 0.0, 1.0));
	col = mix(col, concrete, step(mod(cell.x, aisle_every), 0.5));

	ALBEDO = col;
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
}
