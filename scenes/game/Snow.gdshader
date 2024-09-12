shader_type spatial;
// Global coordinates are important for aligning the path texture.
render_mode world_vertex_coords;

global uniform vec3 player_position;
global uniform sampler2D player_trail;//: repeat_disable;

varying vec2 floor_uv;
varying float edge;
varying float height;
uniform float snow_height = 0.3;

uniform sampler2D color_sample;
uniform sampler2D normal_sample;
uniform sampler2D roughness_sample;


void vertex(){
	vec2 edges = abs(UV - 0.5) * 2.0;
    float maxDist  = max(abs(edges.x), abs(edges.y));
    float circular = length(edges);
    float square   = maxDist;
    edge = smoothstep(mix(circular,square,maxDist), 1.25, 1.0);
	
	floor_uv = vec2(VERTEX.x - player_position.x, VERTEX.z - player_position.z);
	float ratio = 1.0 / 40.0; 
	floor_uv *= vec2(ratio, -ratio);
	floor_uv -= vec2(0.5);
	
	height = 1.0 - texture(player_trail, floor_uv).r;
	height *= edge;
	
	VERTEX.y += snow_height * height;
	
	vec2 texture_increment = 1.0 / vec2(textureSize(player_trail, 0));
	
	// The following calculations for surface normal information are 
	// Approximate derivative along the z axis
	float height_up = 1.0 - texture(player_trail, floor_uv + vec2(0.0, texture_increment.y)).a;
	float height_down = 1.0 - texture(player_trail, floor_uv + vec2(0.0, -texture_increment.y)).a;
	// Approximate derivative along the x axis
	float height_left = 1.0 - texture(player_trail, floor_uv + vec2(-texture_increment.x, 0.0)).a;
	float height_right = 1.0 - texture(player_trail, floor_uv + vec2(texture_increment.x, 0.0)).a;

	BINORMAL = normalize(vec3(1.0, height_right - height_left, 0.0));
	TANGENT = normalize(vec3(0.0, height_up - height_down, 1.0));
	NORMAL = normalize(cross(TANGENT, BINORMAL));
}

void fragment() {
	// Use the snow's height to set its color, darkening the floor.
	float ratio = smoothstep(height, -0.05, 0.00);
	ALBEDO = texture(color_sample, UV).rgb * ratio * 0.5;
	ROUGHNESS = texture(roughness_sample, UV).r;
	NORMAL_MAP = texture(normal_sample, UV).rgb;
}
