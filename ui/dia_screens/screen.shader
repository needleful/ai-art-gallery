shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D viewport;
uniform sampler2D pixel;
uniform vec2 viewport_size;
uniform vec2 uv_scale = vec2(1,1);
varying vec3 screen_normal;

void vertex()
{
	// TODO: XY screen distortion should be relative to the screen
	vec3 v = (WORLD_MATRIX*vec4(VERTEX, 1)).xyz;
	vec3 n = (CAMERA_MATRIX*vec4(NORMAL, 0)).xyz;
	vec3 point_distance = normalize(CAMERA_MATRIX[3].xyz - v);
	point_distance.z = abs(point_distance.z);
	screen_normal = 0.75*point_distance + 0.25*n;
}

void fragment()
{
	float screen_distort = screen_normal.x + screen_normal.y;
	float clamped_distort = clamp(screen_distort, 0, 1);
	screen_distort *= (1.0-screen_normal.z*screen_normal.z);
	SPECULAR = 1.0;
	ROUGHNESS = 0.2;
	METALLIC = 0.1;
	ALBEDO = vec3(clamped_distort);
	EMISSION = 0.75*(
		texture(pixel, UV*viewport_size).xyz*(1.0+screen_distort)*texture(viewport, UV*uv_scale).xyz
		) + 0.01*vec3(1.0-clamped_distort);
}