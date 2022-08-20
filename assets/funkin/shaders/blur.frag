#pragma header

uniform float Directions = 16.0;
uniform float Quality = 3.0;
uniform float Size = 16.0;

void main()
{
    float Pi2 = 6.28318530718;
    vec2 Radius = Size/vec2(1280,720);
    vec4 Color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    
    for( float d=0.0; d<Pi2; d+=Pi2/Directions)
    {
		for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
        {
			Color += flixel_texture2D(bitmap, openfl_TextureCoordv+vec2(cos(d),sin(d))*Radius*i);
        }
    }
    
    Color /= Quality * Directions - 15.0;
    gl_FragColor =  Color;
}