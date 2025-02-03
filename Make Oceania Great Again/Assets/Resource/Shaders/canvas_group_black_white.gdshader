shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 oldColorBlack : source_color;
uniform vec4 newColorBlack : source_color;
uniform vec4 oldColorWhite : source_color;
uniform vec4 newColorWhite : source_color;

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;
	
	float trans = COLOR.a;
	vec3 base_color = vec3(COLOR.r, COLOR.g, COLOR.b);
	vec3 color_black = vec3(oldColorBlack.r, oldColorBlack.g, oldColorBlack.b);
	vec3 color_white = vec3(oldColorWhite.r, oldColorWhite.g, oldColorWhite.b);
	
	if (length(base_color - color_black) < 0.05){
		trans *= newColorBlack.a;
		COLOR = vec4(newColorBlack.r, newColorBlack.g, newColorBlack.b, trans);
		
	}
	if (length(base_color - color_white) < 0.05){
		trans *= newColorWhite.a;
		COLOR = vec4(newColorWhite.r, newColorWhite.g, newColorWhite.b, trans);
	}
}

