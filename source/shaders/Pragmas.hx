package shaders;

class Pragmas {
    public static var entireFuckingCustomFragmentHeaderThatIStoleFromYCE = "
    
    varying float openfl_Alphav;
    varying vec4 openfl_ColorMultiplierv;
    varying vec4 openfl_ColorOffsetv;
    varying vec2 openfl_TextureCoordv;

    uniform bool openfl_HasColorTransform;
    uniform vec2 openfl_TextureSize;
    uniform sampler2D bitmap;

    uniform bool hasTransform;
    uniform bool hasColorTransform;

    vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
    {
        vec4 color = texture2D(bitmap, coord);
        if (!hasTransform)
        {
            return color;
        }

        if (color.a == 0.0)
        {
            return vec4(0.0, 0.0, 0.0, 0.0);
        }

        if (!hasColorTransform)
        {
            return color * openfl_Alphav;
        }

        color = vec4(color.rgb / color.a, color.a);

        mat4 colorMultiplier = mat4(0);
        colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
        colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
        colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
        colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

        color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

        if (color.a > 0.0)
        {
            return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
        }
        return vec4(0.0, 0.0, 0.0, 0.0);
    }

    uniform vec4 _camSize;

    vec2 getCamPos(vec2 pos) {
        return (pos * openfl_TextureSize / vec2(_camSize.z, _camSize.w)) + vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z);
    }
    vec2 camToOg(vec2 pos) {
        return ((pos - vec2(_camSize.x / _camSize.z, _camSize.y / _camSize.z)) * vec2(_camSize.z, _camSize.w) / openfl_TextureSize);
    }
    vec4 textureCam(sampler2D bitmap, vec2 pos) {
        return texture2D(bitmap, camToOg(pos));
    }
    ";
}