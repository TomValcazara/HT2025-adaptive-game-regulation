shader_type canvas_item;

uniform float time_factor = 0.8;
uniform vec2 amplitude = vec2(20.0,20.0);
uniform bool enable = true;

void vertex(){
	if (enable){
		VERTEX.x += cos(TIME * time_factor + VERTEX.x) * amplitude.x;
		VERTEX.y+= sin(TIME * time_factor + VERTEX.y) * amplitude.y;
	}
}