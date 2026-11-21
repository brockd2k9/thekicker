// Gradient sky with soft static clouds (no TIME, so the sky is only rendered once).
shader_type sky;

#include "res://shaders/noise.gdshaderinc"

uniform vec3 top_color : source_color = vec3(0.15, 0.36, 0.78);
uniform vec3 horizon_color : source_color = vec3(0.64, 0.79, 0.95);
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float cloud_cover : hint_range(0.0, 1.0) = 0.45;
uniform float stars : hint_range(0.0, 1.0) = 0.0; // night games

void sky() {
	float y = max(EYEDIR.y, 0.0);
	vec3 col = mix(horizon_color, top_color, pow(y, 0.55));
	if (EYEDIR.y > 0.0) {
		vec2 uv = EYEDIR.xz / (EYEDIR.y + 0.1) * 1.4;
		float c = fbm(uv);
		c = smoothstep(1.0 - cloud_cover, 1.0 - cloud_cover + 0.3, c);
		c *= smoothstep(0.0, 0.2, EYEDIR.y);
		col = mix(col, cloud_color, c * 0.8);
		if (stars > 0.0) {
			vec2 cell = floor(EYEDIR.xz / (EYEDIR.y + 0.3) * 160.0);
			float s = step(0.996, hash12(cell)) * smoothstep(0.05, 0.4, EYEDIR.y) * (1.0 - c);
			col += vec3(s * stars * 0.8);
		}
	} else {
		col = horizon_color * 0.9;
	}
	COLOR = col;
}
