package funkin.game;

import flixel.FlxSprite;

class FunkinSprite extends FlxSprite
{
    public var animList:Array<String> = [];
    public var animOffsets:Map<String, Array<Float>> = [];

    public function new(x:Float, y:Float)
    {
        super(x, y);

        antialiasing = true;
    }

    /**
        Easily add an animation with the following parameters:

        @param name      The name used in the `playAnim` function.
        @param prefix    The name used in the XML/TXT itself.
        @param fps       The framerate of the animation.
        @param offsets   X and Y offsets for this animation (Optional, because default is [0, 0])
    **/
    public function addAnimByPrefix(name:String, prefix:String, fps:Int, looped:Bool = false, ?offsets:Null<Array<Float>>)
    {
        animList.push(name);
        animation.addByPrefix(name, prefix, fps, looped);
        if(offsets != null)
            animOffsets.set(name, offsets);
        else
            animOffsets.set(name, [0, 0]);
    }

    /**
        Easily add an animation with indices using the following parameters:

        @param name      The name used in the `playAnim` function.
        @param prefix    The name used in the XML/TXT itself.
        @param indices   Specifies what frames play and what order they play in.
        @param fps       The framerate of the animation.
        @param offsets   X and Y offsets for this animation (Optional, because default is [0, 0])
    **/
    public function addAnimByIndices(name:String, prefix:String, indices:Array<Int>, fps:Int, looped:Bool = false, ?offsets:Null<Array<Float>>)
    {
        animList.push(name);
        animation.addByIndices(name, prefix, indices, "", fps, looped);
        if(offsets != null)
            animOffsets.set(name, offsets);
        else
            animOffsets.set(name, [0, 0]);
    }

    /**
        Play an animation (if you added it with `addAnimByPrefix`, `addAnimByIndices`, or `addAnim`).

        @param name     The animation to play.
        @param force    Forces the animation to play regardless of if it's already playing or not.
    **/
    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        animation.play(name, force, reversed, frame);
        if(animOffsets.exists(name))
            offset.set(animOffsets[name][0], animOffsets[name][1]);
        else
        {
            animOffsets.set(name, [0, 0]);
            offset.set(0, 0);
        }
    }

    /**
        Removes an animation. That's it.

        @param anim      The thing to remove.
    **/
    public function removeAnim(anim:String)
    {
        if(animation.exists(anim))
            animation.remove(anim);
        
        if(animList.contains(anim))
            animList.remove(anim);

        playAnim(animList[0], true);
    }
}