// Kicking net: a see-through mesh grid with a ripple that spreads from where
// the ball hit. One draw call; the ripple is only animated (by KickingNet)
// for a moment after a hit, so an idle net costs nothing extra per frame.
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, unshaded;

uniform vec3 cord_color : source_color = vec3(0.92, 0.93, 0.95);
// Mesh cells across the width and up the height.
uniform vec2 cells = vec2(18.0, 20.0);
uniform float cord_width = 0.12;
// Ripple: hit point in the plane's UV, seconds since the hit (< 0 = none).
uniform vec2 hit_uv = vec2(0.5, 0.5);
uniform float ripple_t = -1.0;
uniform float ripple_amp = 0.35;
uniform vec2 plane_size = vec2(3.6, 4.0);

float ripple(vec2 uv) {
	if (ripple_t < 0.0) {
		return 0.0;
	}
	float d = length((uv - hit_uv) * plane_size);
	// A bulge at the hit that spreads out as a wave and dies away.
	float wave = sin(d * 5.0 - ripple_t * 18.0) * exp(-d * 1.2);
	float bulge = exp(-d * d * 3.0);
	return ripple_amp * exp(-ripple_t * 4.5) * (bulge + 0.5 * wave);
}

void vertex() {
	// Push back (away from the kicker = the plane's -Z after rotation, i.e. along -NORMAL).
	VERTEX -= NORMAL * ripple(UV);
}

void fragment() {
	vec2 g = fract(UV * cells);
	vec2 w = fwidth(UV * cells) + cord_width * 0.5;
	float cord = max(1.0 - smoothstep(w.x * 0.5, w.x, min(g.x, 1.0 - g.x)),
		1.0 - smoothstep(w.y * 0.5, w.y, min(g.y, 1.0 - g.y)));
	ALBEDO = cord_color;
	ALPHA = clamp(cord, 0.0, 1.0) * 0.7 + 0.04;
}
