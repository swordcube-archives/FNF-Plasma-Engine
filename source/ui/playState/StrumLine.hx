package ui.playState;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class StrumLine extends FlxTypedSpriteGroup<StrumNote>
{
    public var keyCount:Int = 4;
    public var skin:String = "arrows";
    
    public function new(x:Float, y:Float, skin:String, ?keyCount:Int = 4)
    {
        super(x, y);
        this.keyCount = keyCount;
        this.skin = skin;
        reloadStrums();
    }

    public function reloadStrums()
    {
        for(strum in members)
        {
            members.remove(strum);
            strum.kill();
            strum.destroy();
        }

        for(i in 0...keyCount)
        {
            var strum:StrumNote = new StrumNote(Note.swagWidth * i, 0, skin, i, keyCount);
			strum.y -= 10;
			strum.alpha = 0;
            add(strum);
            
			FlxTween.tween(strum, {y: strum.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
        }
    }
}