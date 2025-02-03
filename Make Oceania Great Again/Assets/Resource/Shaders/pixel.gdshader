shader_type canvas_item;

uniform bool uniform_texture = true;
uniform bool use_height = false;
uniform int pixel_size_uniform = 240;
uniform vec2 pixel_size = vec2(240, 240);

void fragment() {
	vec2 texture_size = vec2(textureSize(TEXTURE, 0));
	if (use_height){
		texture_size /= texture_size.y;
	}else{
		texture_size /= texture_size.x;
	}
	
	vec2 grid_uv;
	
	if (uniform_texture){
		grid_uv = floor(UV * float(pixel_size_uniform) * texture_size) / (float(pixel_size_uniform) * texture_size);
	}else{
		grid_uv = floor(UV * pixel_size) / pixel_size;
	}
	
	vec4 text = texture(TEXTURE, grid_uv);
	//text.a = COLOR.a;
	
	COLOR = text;
}
