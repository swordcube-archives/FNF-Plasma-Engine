package funkin.shaders;

// This shader was made by YoshiCrafter29
class OutlineShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

    float diff = 7;
    int step = 3;
    float sin45 = sin(radians(45.0));
    uniform vec4 cuttingEdge;
    
    float motherfuckingAbs(float v) {
        if (v < 0)
            return -v;
        return v;
    }
    vec4 flixel_texture2D_safe(sampler2D bitmap, vec2 pos) {
        if (pos.x < cuttingEdge.x || pos.x > cuttingEdge.x + cuttingEdge.z || pos.y < cuttingEdge.y || pos.y > cuttingEdge.y + cuttingEdge.w)
             return vec4(0, 0, 0, 0);
        else
        if (pos.x < 0. || pos.x > 1. || pos.y < 0. || pos.y > 1.)
            return vec4(0, 0, 0, 0);
        else
            return flixel_texture2D(bitmap, pos);
    }
    
    void main() {
        vec2 newPos = vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y);
        newPos -= vec2(cuttingEdge.x + (cuttingEdge.z / 2.0), cuttingEdge.y + (cuttingEdge.w / 2.0));
        newPos *= vec2(1.5, 1.5);
        newPos += vec2(cuttingEdge.x + (cuttingEdge.z / 2.0), cuttingEdge.y + (cuttingEdge.w / 2.0));
    
    
        vec4 color = flixel_texture2D_safe(bitmap, newPos);
        float a = 0;
        for(int x = -int(diff); x < int(diff); x += step) {
            for(int y = -int(diff); y < int(diff); y += step) {
                vec2 offset = vec2(x / openfl_TextureSize.x, y / openfl_TextureSize.y);
                float angle = atan(offset.y, offset.x);
                offset = vec2(cos(angle) * (motherfuckingAbs(x) / openfl_TextureSize.x), sin(angle) * (motherfuckingAbs(y) / openfl_TextureSize.y));

                vec4 c1 = flixel_texture2D_safe(bitmap, newPos + offset);
                if (a < c1.a) a = c1.a;
            }
        }

        // disable for cool non intended shadow
        /*
        float a = 0;
        for(int i = 0; i < 8; ++i) {
            vec2 pos = vec2(0, 0);
            switch(i) {
                case 0:
                    pos = vec2(0, -diff);
                case 1:
                    pos = vec2((diff * sin45), (diff * -sin45));
                case 2:
                    pos = vec2(diff, 0);
                case 3:
                    pos = vec2((diff * sin45), (diff * sin45));
                case 4:
                    pos = vec2(0, diff);
                case 5:
                    pos = vec2((diff * -sin45), (diff * sin45));
                case 6:
                    pos = vec2(-diff, 0);
                case 7:
                    pos = vec2((diff * -sin45), (diff * -sin45));
            }
            vec4 c1 = flixel_texture2D_safe(bitmap, newPos + (pos / openfl_TextureSize));
            if (a < c1.a) {
                a = c1.a;
            }
        }
        */
    
        gl_FragColor = vec4(color.r, color.g, color.b, a);
    }')

    public function new() {
        super();
        this.cuttingEdge.value = [0, 0, 1, 1];
    }

    public function setClip(x:Float, y:Float, w:Float, h:Float) {
        this.cuttingEdge.value = [x, y, w, h];
    }
}