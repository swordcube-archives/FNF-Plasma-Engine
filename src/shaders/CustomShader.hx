package shaders;

import flixel.addons.display.FlxRuntimeShader;

class CustomShader extends FlxRuntimeShader {
    public function new(frag:String = null, vert:String = null, glslVersion:Int = 120) {
        if(vert == null) vert = frag;
        super(frag, vert, glslVersion);
    }
}