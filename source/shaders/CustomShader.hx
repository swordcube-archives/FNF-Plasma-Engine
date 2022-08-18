package shaders;

import openfl.display.ShaderParameter;
import shaders.FlxFixedShader;
import shaders.Pragmas;

using StringTools;

class CustomShader extends FlxFixedShader
{
    public static var current:CustomShader;

    public function new()
    {
        super();
        current = this;
    }

    public var shaderData(get, null):Dynamic;
    private function get_shaderData() {
        return __data;
    }
    public function setValue(name:String, value:Dynamic) {
        if (Reflect.getProperty(data, name) != null) {
            var d:ShaderParameter<Dynamic> = Reflect.getProperty(data, name);
            Reflect.setProperty(d, "value", [value]);
        }
    }

    public function loadFragDumb(frag:String) {
        this.glFragmentSource = FNFAssets.returnAsset(TEXT, AssetPaths.frag(frag)).replace("#pragma header", Pragmas.entireFuckingCustomFragmentHeaderThatIStoleFromYCE);
        return this;
    }
    public function loadVertDumb(vert:String) {
        this.glVertexSource = FNFAssets.returnAsset(TEXT, AssetPaths.frag(vert));
        return this;
    }

    public static function loadFrag(frag:String)
        return current.loadFragDumb(frag);

    public static function loadVert(vert:String)
        return current.loadVertDumb(vert);
}