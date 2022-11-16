package shaders;

import flixel.addons.display.FlxRuntimeShader;

class CustomShader extends FlxRuntimeShader
{
    public function new(?frag:String, ?vert:String = null, glslVersion:Int = 120) {
        super(frag, vert, glslVersion);
    }
}
