package shaders;

import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameterType;
import openfl.display.ShaderParameter;

using StringTools;

class CustomShader extends FlxFixedShader
{
    public function new(?frag:String, ?vert:String) {
        if (FNFAssets.returnAsset(TEXT, AssetPaths.frag(frag)) != '')
            this.glFragmentSource = StringTools.replace(cast(FNFAssets.returnAsset(TEXT, AssetPaths.frag(frag)), String), '#pragma header', Pragmas.fragHead);
        else if (frag != null)
            Main.print('warn', 'Could not find fragment shader "' + frag + '"');

        if (FNFAssets.returnAsset(TEXT, AssetPaths.frag(vert)) != '')
            this.glVertexSource = FNFAssets.returnAsset(TEXT, AssetPaths.frag(vert));
        else if (vert != null)
            Main.print('warn', 'Could not find fragment shader "' + vert + '"');

        super();
    }
}