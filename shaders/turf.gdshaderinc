// The playing surface: mown grass and painted markings, all computed from the
// world position (the field has no UVs and no texture files).
// Built in variants by TurfShader (scripts/visual/turf_shader.gd), which puts
// "shader_type spatial;" and some of these defines in front of this file:
//   TURF_GRASS       mowing stripes that react to the light, color variation,
//                    blade grain, wind gusts rolling across the field
//   TURF_GRASS_HIGH  + worn turf between the hashes, blade-level normals, sheen
//   TURF_PAINT       full markings: 6 ft white border, 4 in yard lines, 8 in
//                    goal lines, inbound and sideline hash marks, yard numbers
//                    with arrows, try line, end zone color and lettering
// Without TURF_GRASS the grass is the old flat two-tone; without TURF_PAINT
// the lines are the old thin ones.

const float YARD = 0.9144;

uniform float goal_z = -36.0; // world Z of the end line (where the posts stand)
uniform vec3 grass_light : source_color = vec3(0.26, 0.56, 0.22);
uniform vec3 grass_dark : source_color = vec3(0.19, 0.46, 0.17);
uniform vec3 endzone_color : source_color = vec3(0.09, 0.18, 0.46);
uniform vec3 line_color : source_color = vec3(0.96, 0.96, 0.93);
uniform vec3 outside_color : source_color = vec3(0.15, 0.34, 0.15);
uniform float field_half_width = 24.38;
uniform float grain_strength = 0.4;
uniform float hash_x = 3.12; // hash marks' distance from the middle (m), by stage
uniform sampler2D noise_tex : filter_linear_mipmap_anisotropic, repeat_enable, hint_default_white;

#ifdef TURF_GRASS
// Wind over the grass: direction (world xz) times strength (0 calm .. 1 gale).
uniform vec2 wind_vec = vec2(0.0);
// 1 = checkerboard mowing (big stadiums), 0 = stripes across the field.
uniform float checker = 0.0;
// Horizontal direction to the sun (world xz) times how far the mower lays the
// blades over: light stripes lean toward the light, dark ones away from it.
uniform vec2 stripe_tilt = vec2(-0.14, 0.06);
uniform vec3 dry_tint : source_color = vec3(0.47, 0.5, 0.2);
uniform vec3 worn_tint : source_color = vec3(0.3, 0.33, 0.16);
#endif

#ifdef TURF_PAINT
// Digits 0-5 side by side, white on black (FieldPaint).
uniform sampler2D digits_tex : filter_linear_mipmap, repeat_disable, hint_default_black;
// End zone lettering, white on black.
uniform sampler2D wordmark_tex : filter_linear_mipmap, repeat_disable, hint_default_black;
// Yard line of the try (extra point) mark: 2 pro, 3 college and high school.
uniform float try_yd = 2.0;
uniform vec3 wordmark_color : source_color = vec3(0.96, 0.96, 0.93);
#endif

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Coverage of a line of half-width hw around dist = 0. Antialiased up close;
// far away (thinner than a pixel) it fades by the share of the pixel it covers.
float line_mask(float dist, float hw) {
	float w = fwidth(dist) + 0.0001;
	return clamp((hw - dist) / w + 0.5, 0.0, 1.0) * clamp(2.0 * hw / w, 0.0, 1.0);
}

// Coverage of the band lo..hi along one axis.
float band_mask(float v, float lo, float hi) {
	return line_mask(abs(v - (lo + hi) * 0.5), (hi - lo) * 0.5);
}

void fragment() {
	vec2 p = world_pos.xz;
	float yd = (p.y - goal_z) / YARD; // yards from the end line toward the kicker
	float fyd = min(yd, 120.0 - yd); // the same from the nearer end line
	float ax = abs(p.x);
	float inside = step(ax, field_half_width) * step(0.0, fyd);
	float in_play = inside * step(10.0, fyd);

	// --- grass -------------------------------------------------------------------
	float band = floor((yd - 10.0) / 5.0);
	float lean = mod(band, 2.0) < 1.0 ? 1.0 : -1.0;
	vec3 n_world = vec3(0.0, 1.0, 0.0);
	float rough = 0.92;
	float spec = 0.25;
#ifdef TURF_GRASS
	if (checker > 0.5) {
		lean *= mod(floor((p.x + field_half_width) / (5.0 * YARD)), 2.0) < 1.0 ? 1.0 : -1.0;
	}
	lean *= inside; // the apron is mown one way
	// Wind: gusts travel downwind and lay the blades over as they pass.
	float wind_amt = length(wind_vec);
	vec2 wind_dir = wind_vec / max(wind_amt, 0.001);
	float gust = texture(noise_tex, p * 0.011 - wind_dir * TIME * (0.02 + 0.07 * wind_amt)).r - 0.5;
	vec2 sway = wind_dir * (gust * (0.25 + 1.3 * wind_amt));
	// Blade grain, stretched along the field; it shivers a little in the wind.
	float flutter = sin(TIME * (2.0 + 5.0 * wind_amt) + p.x * 1.7 + p.y * 0.9) * 0.012 * (0.3 + wind_amt);
	float blades = texture(noise_tex, p * vec2(2.9, 0.8) + wind_dir * flutter).r - 0.5;
	float clumps = texture(noise_tex, p * 0.21 + vec2(0.37, 0.11)).r - 0.5;
	float patches = texture(noise_tex, p * 0.0071 + vec2(0.61, 0.83)).r - 0.5;

	// Mowing stripes: the mower lays the blades over one way, then the other.
	// Leaning blades catch the light differently, so the stripe contrast comes
	// from both the color and the tilted normal (it shifts with the sun).
	float tone = 0.5 + 0.5 * lean + sway.x * 0.35 + sway.y * 0.2;
	vec3 col = mix(grass_dark, grass_light, clamp(tone, -0.2, 1.2));
	col = mix(col, dry_tint, clamp(patches * 0.8 + clumps * 0.12, 0.0, 0.3));
	col *= 1.0 + grain_strength * (blades * 1.1 + clumps * 0.3) + patches * 0.16;
	n_world = normalize(vec3(lean * stripe_tilt.x + sway.x * 0.5, 1.0, lean * stripe_tilt.y + sway.y * 0.5));
#ifdef TURF_GRASS_HIGH
	// Worn turf where the game is played: between the hashes and at the goal mouth.
	float lane = 1.0 - smoothstep(hash_x * 0.6, hash_x + 2.5, ax);
	float wear = lane * in_play * clamp(0.35 + clumps * 1.6 + patches * 1.2, 0.0, 1.0);
	col = mix(col, worn_tint, wear * 0.22);
	// Blade-level normals close to the camera, and a soft sheen at grazing angles.
	float fine = texture(noise_tex, p * vec2(13.0, 4.7) + vec2(0.013, 0.07) + wind_dir * flutter * 3.0).r - 0.5;
	col *= 1.0 + grain_strength * fine * 1.3;
	n_world = normalize(n_world + vec3(fine, 0.0, blades) * 0.3);
	rough = 0.8;
	spec = 0.32;
#endif
	col = mix(outside_color * (1.0 + grain_strength * (blades + clumps * 0.3)), col,
		clamp(inside + (1.0 - step(field_half_width + 9.0, ax)) * step(-9.0, fyd) * 0.75, 0.0, 1.0));
#else
	vec3 col = lean > 0.0 ? grass_light : grass_dark;
	if (inside < 0.5) {
		col = outside_color;
	}
	float blades = texture(noise_tex, p * vec2(2.9, 0.8)).r - 0.5;
	float clumps = texture(noise_tex, p * 0.21 + vec2(0.37, 0.11)).r - 0.5;
	col *= 1.0 + grain_strength * (blades + clumps * 0.6);
#endif

	// --- paint -------------------------------------------------------------------
	float paint = 0.0;
	vec3 paint_col = line_color;
#ifdef TURF_PAINT
	float edge = field_half_width - ax; // m inside the sideline
	float back = fyd * YARD; // m inside the end line
	// End zone: team color with the lettering across it (read from the field).
	float ez = inside * (1.0 - step(10.0, fyd));
	if (ez > 0.5) {
		float far_end = step(60.0, yd);
		vec2 wuv = vec2(p.x / 37.0 + 0.5, (fyd - 2.3) / 5.4);
		wuv = mix(wuv, vec2(1.0) - wuv, far_end);
		float letters = 0.0;
		if (wuv.x > 0.0 && wuv.x < 1.0 && wuv.y > 0.0 && wuv.y < 1.0) {
			letters = texture(wordmark_tex, wuv).r;
		}
		// Paint soaks into the grass: it keeps a little of the stripe and grain.
		vec3 fill = endzone_color * (0.86 + 0.14 * step(0.5, 0.5 + 0.5 * lean));
		paint_col = mix(fill, wordmark_color, letters);
		paint = 0.9 + 0.1 * letters;
	}
	// 6 ft white border around the field.
	float out_d = max(-edge, -back);
	float border = band_mask(out_d, 0.0, 1.83);
	// Yard lines every 5 yards (4 in, stopping short of the sidelines); goal lines 8 in.
	float zy = (fyd - 10.0) / 5.0;
	float d5 = abs(zy - round(zy)) * 5.0 * YARD;
	float is_goal = step(abs(fyd - 10.0), 1.0);
	float lines = line_mask(d5, mix(0.051, 0.1, is_goal)) * step(9.5, fyd) * step(mix(0.2, 0.0, is_goal), edge);
	// Hash marks every yard, 2 ft long: the inbound lines and along both sidelines.
	float d1 = abs(fyd - round(fyd)) * YARD;
	float hashes = max(band_mask(ax, hash_x - 0.305, hash_x + 0.305), band_mask(edge, 0.1, 0.71));
	lines = max(lines, line_mask(d1, 0.051) * hashes * step(10.5, fyd));
	// Try line: one yard wide in the middle of the field.
	lines = max(lines, line_mask(abs(fyd - 10.0 - try_yd) * YARD, 0.051) * band_mask(ax, -0.46, 0.46));
	// Yard numbers every 10 yards, 6 ft tall, read from the nearer sideline,
	// with an arrow toward the nearer goal line.
	float ten = round((fyd - 10.0) / 10.0);
	if (ten >= 1.0 && ten <= 5.0 && ax > 11.0 && ax < 14.0) {
		float side = sign(p.x);
		float line_yd = fyd < yd ? 110.0 - ten * 10.0 : 10.0 + ten * 10.0;
		float along = -side * (yd - line_yd) * YARD; // + = the reader's right
		float up = (13.41 - ax) / 1.83; // 0 at the foot of the digit, 1 at the top
		float cell = (abs(along) - 0.32) / 1.22;
		if (cell > 0.0 && cell < 1.0 && up > 0.0 && up < 1.0) {
			float digit = along < 0.0 ? ten : 0.0;
			float u = along < 0.0 ? 1.0 - cell : cell;
			vec2 duv = vec2((digit + u) / 6.0, 1.0 - up);
			// Explicit gradients: no seam where the two digits' cells meet.
			vec2 g = vec2(-side * YARD / (1.22 * 6.0), 1.0 / 1.83);
			lines = max(lines, textureGrad(digits_tex, duv, dFdx(yd) * vec2(g.x, 0.0) + dFdx(ax) * vec2(0.0, g.y),
				dFdy(yd) * vec2(g.x, 0.0) + dFdy(ax) * vec2(0.0, g.y)).r);
		}
		// Arrow beside the number, pointing at the nearer goal line (none at the 50).
		float toward = (10.0 + ten * 10.0 - fyd) * YARD - 1.72; // m past the digit
		if (ten < 4.5 && toward > 0.0 && toward < 0.9) {
			lines = max(lines, line_mask(abs(up - 0.74) * 1.83, 0.23 * (1.0 - toward / 0.9)));
		}
	}
	lines = max(lines, border);
	paint_col = mix(paint_col, line_color, lines);
	paint = max(paint, lines);
#else
	// The old markings: thin yard lines, goal line, hash marks, sidelines.
	if (yd < 10.0 && inside > 0.5) {
		paint_col = endzone_color * (0.92 + 0.08 * step(0.5, fract((p.x + p.y) * 0.25)));
		paint = 1.0;
	}
	float lines = 0.0;
	if (ax <= field_half_width + 0.1 && yd >= -0.1) {
		float zy = (yd - 10.0) / 5.0;
		float d5 = abs(zy - round(zy)) * 5.0 * YARD;
		float hw = abs(yd - 10.0) < 1.0 ? 0.1 : 0.05; // goal line is wider
		if (yd >= 9.9) {
			lines = max(lines, line_mask(d5, hw));
		}
		lines = max(lines, line_mask(abs(p.y - goal_z), 0.06));
		float d1 = abs(yd - round(yd)) * YARD;
		if (yd > 10.0) {
			lines = max(lines, line_mask(d1, 0.05) * step(abs(ax - hash_x), 0.3));
		}
	}
	lines = max(lines, line_mask(abs(ax - field_half_width), 0.1) * step(-0.1, yd));
	paint_col = mix(paint_col, line_color, lines);
	paint = max(paint, lines);
#endif
	// Painted grass still shows its grain.
	col = mix(col, paint_col * (1.0 + grain_strength * (blades * 0.5 + clumps * 0.35)), paint);

	ALBEDO = col;
	NORMAL = normalize((VIEW_MATRIX * vec4(n_world, 0.0)).xyz);
	ROUGHNESS = mix(rough, 0.95, paint);
	SPECULAR = spec;
}
