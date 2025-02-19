/* 
@LURGX 2024 Select player animation how in the 80s
*/
shader_type canvas_item;


uniform float line_scale : hint_range(0, 1.5) = 0.0;    // Line strech
uniform float frequency : hint_range(0.0, 5.0) = 3;  // frequency of the Shain Color
uniform float alpha : hint_range(0.0, 2.0) = 1.0; //ALPHA

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;
	vec2 si = TEXTURE_PIXEL_SIZE * line_scale;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.5);
	
	float outs = texture(TEXTURE, UV-outline).a;

	vec4 animated_line_color = vec4(0.5 + sin(2.0*3.14*frequency*TIME),
							   0.5 + sin(2.0*3.14*frequency*TIME + radians(120.0)),
							   0.5 + sin(2.0*3.14*frequency*TIME + radians(240.0)),
							   alpha);
	
	vec4 color = texture(TEXTURE, UV);
	vec4 c = texture(TEXTURE, TEXTURE_PIXEL_SIZE);
	COLOR = mix(color,animated_line_color+alpha, outline - color.a);


}