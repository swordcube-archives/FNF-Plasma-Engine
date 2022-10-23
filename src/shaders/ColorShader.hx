package shaders;

class ColorShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

        uniform vec3 color;
        uniform bool enabled;
        
        void main() {
            vec4 finalColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (enabled) {
                float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
                gl_FragColor = vec4(((finalColor.g + finalColor.b) / 2.0) + (color.r/255 * diff), finalColor.g + (color.g/255 * diff), finalColor.b + (color.b/255 * diff), finalColor.a);
            } else {
                gl_FragColor = finalColor;
            }
        }
    ')
    public function new(r:Int, g:Int, b:Int) {
        super();
        setColors(r, g, b);
        this.enabled.value = [true];
    }

    public function setColors(r:Int, g:Int, b:Int) {
        this.color.value = [r, g, b];
    }
}