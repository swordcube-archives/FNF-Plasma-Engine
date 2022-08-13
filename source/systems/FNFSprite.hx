package systems;

import flixel.FlxSprite;

class FNFSprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Int>> = [];

    public function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        if(animation.exists(anim))
        {
            animation.play(anim, force, reversed, frame);
            
            if(animOffsets.exists(anim))
                offset.set(animOffsets.get(anim)[0], animOffsets.get(anim)[1]);
            else
                offset.set(0, 0);
        }
    }

    public function setOffset(anim:String, x:Int = 0, y:Int = 0)
    {
        animOffsets.set(anim, [x, y]);
    }
}