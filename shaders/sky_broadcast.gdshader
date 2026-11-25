// Broadcast sky: a sun-aware gradient (deeper blue overhead, bright haze at the
// horizon, a warm glow around the sun), a sun disc and two layers of lit clouds.
// It lights the scene too (sky ambient light and reflections).
// Clouds come from a small noise texture (two taps on LOW, four on HIGH) and
// there is no TIME, so the lighting cubemap is only rendered once.
shader_type sky;

uniform vec3 top_color : source_color = vec3(0.10, 0.27, 0.66);
uniform vec3 horizon_color : source_color = vec3(0.58, 0.74, 0.93);
uniform vec3 haze_color : source_color = vec3(0.86, 0.90, 0.95);
uniform vec3 ground_color : source_color = vec3(0.20, 0.27, 0.19);
uniform vec3 cloud_color : source_color = vec3(1.0, 0.99, 0.97);
uniform vec3 cloud_shade : source_color = vec3(0.52, 0.58, 0.70);
uniform float cloud_cover : hint_range(0.0, 1.0) = 0.42;
// 1 = clouds shaded by the sun's direction (two more texture taps).
uniform float cloud_detail : hint_range(0.0, 1.0) = 1.0;
// Sun disc and glow (0 at night: the key light is the stadium lights).
uniform float sun_amount : hint_range(0.0, 1.0) = 1.0;
uniform float stars : hint_range(0.0, 1.0) = 0.0;
// Night: the stadium lights' glow on the low sky.
uniform vec3 light_dome : source_color = vec3(0.0, 0.0, 0.0);
uniform float energy = 1.0;
uniform sampler2D noise_tex : filter_linear_mipmap, repeat_enable, hint_default_white;

float cloud_density(vec2 uv) {
	float n = texture(noise_tex, uv * 0.11).r * 0.65 + texture(noise_tex, uv * 0.37 + vec2(0.31, 0.57)).r * 0.35;
	return smoothstep(1.0 - cloud_cover - 0.12, 1.0 - cloud_cover + 0.22, n);
}

float star_hash(vec2 p) {
	p = mod(p, 289.0);
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void sky() {
	vec3 dir = EYEDIR;
	float y = max(dir.y, 0.0);
	vec3 sun_dir = LIGHT0_ENABLED ? LIGHT0_DIRECTION : vec3(0.0, 1.0, 0.0);
	float to_sun = max(dot(dir, sun_dir), 0.0);

	vec3 col = mix(horizon_color, top_color, 1.0 - pow(1.0 - y, 2.6));
	col = mix(col, haze_color, pow(1.0 - y, 9.0) * 0.75);
	// Warm scattering around the sun, strongest low in the sky.
	vec3 sun_tint = mix(vec3(1.0, 0.86, 0.66), vec3(1.0, 0.97, 0.9), clamp(sun_dir.y * 1.6, 0.0, 1.0));
	col += sun_tint * (pow(to_sun, 6.0) * 0.16 + pow(to_sun, 48.0) * 0.3) * sun_amount;
	col += light_dome * pow(1.0 - y, 5.0);

	if (dir.y > 0.0) {
		vec2 uv = dir.xz / (dir.y + 0.12);
		float c = cloud_density(uv);
		if (c > 0.001) {
			// Lit side toward the sun, grey bases away from it.
			float lit = 0.6;
			if (cloud_detail > 0.5) {
				float toward = cloud_density(uv + normalize(sun_dir.xz + vec2(0.0001)) * 0.35);
				lit = clamp(0.95 - toward * 0.75, 0.0, 1.0);
			}
			vec3 cc = mix(cloud_shade, cloud_color, lit);
			cc += sun_tint * pow(to_sun, 4.0) * 0.25 * sun_amount;
			c *= smoothstep(0.0, 0.16, dir.y); // melt into the horizon haze
			col = mix(col, cc, c * 0.9);
		}
		if (stars > 0.0) {
			vec2 cell = floor(dir.xz / (dir.y + 0.3) * 160.0);
			float s = step(0.996, star_hash(cell)) * smoothstep(0.05, 0.4, dir.y) * (1.0 - c);
			col += vec3(s * stars * 0.8);
		}
		// Sun disc with a soft edge.
		col += sun_tint * smoothstep(0.9993, 0.9997, to_sun) * 4.0 * sun_amount * (1.0 - c);
	} else {
		col = mix(mix(horizon_color, haze_color, 0.75), ground_color, smoothstep(0.0, -0.12, dir.y));
	}
	COLOR = col * energy;
}
