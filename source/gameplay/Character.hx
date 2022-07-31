package gameplay;

import flixel.math.FlxPoint;
import hscript.HScript;
import sys.FileSystem;
import systems.FNFSprite;

class Character extends FNFSprite
{
    public var script:HScript;
    public var curCharacter:String = "bf";

    public var isLikeGF:Bool = false;
    public var canDance:Bool = false;

    public var cameraPosition:FlxPoint = new FlxPoint();
    public var ogPosition:FlxPoint = new FlxPoint();

    public function new(x:Float, y:Float, char:String, isPlayer:Bool = false)
    {
        super(x, y);
        curCharacter = char;
        
        ogPosition = new FlxPoint(x, y);

        var path:String = AssetPaths.hxs('characters/$char/script');
        if(!FileSystem.exists(path))
            path = AssetPaths.hxs('characters/bf/script');

        script = new HScript(path);
        script.setVariable("character", this);
        script.start();
        script.callFunction("createPost");
    }

    var danced:Bool = false;

    public function dance()
    {
        if(isLikeGF)
        {
            if(canDance)
            {
                if(animation.curAnim != null && (animation.curAnim.name != "hairBlow" || animation.curAnim.name != "hairFall") && animation.curAnim.finished)
                {
                    danced = !danced;
                    if(danced)
                        playAnim("danceRight");
                    else
                        playAnim("danceLeft");
                }
            }
        }
        else
        {
            if(canDance)
                playAnim("idle");
        }
    }
}