package gameplay;

import flixel.math.FlxPoint;
import hscript.HScript;
import sys.FileSystem;
import systems.Conductor;
import systems.FNFSprite;

using StringTools;

class Character extends FNFSprite
{
    public var script:HScript;
    public var curCharacter:String = "bf";

    public var isLikeGF:Bool = false;
    public var canDance:Bool = true;

    public var isPlayer:Bool = false;

    public var singDuration:Float = 4;

    public var heyTimer:Float = 0;
    public var holdTimer:Float = 0.0;

    public var specialAnim:Bool = false;
    public var debugMode:Bool = false;

    public var cameraPosition:FlxPoint = new FlxPoint();

    public var positionOffset:FlxPoint = new FlxPoint();

    public var ogPosition:FlxPoint = new FlxPoint();

    public function new(x:Float, y:Float, char:String, isPlayer:Bool = false)
    {
        super(x, y);

        antialiasing = Init.trueSettings.get("Antialiasing");
        
        this.isPlayer = isPlayer;
        curCharacter = char;

        var path:String = 'characters/$char/script';
        if(!FileSystem.exists(AssetPaths.hxs(path)))
            path = 'characters/bf/script';

        script = new HScript(path);
        script.setVariable("character", this);
        script.start();

        this.x += positionOffset.x;
        this.y += positionOffset.y;

        ogPosition = new FlxPoint(x, y);

        script.callFunction("createPost");
    }

    public function goToPosition(X:Float, Y:Float)
    {
        super.setPosition(X, Y);

        this.x += positionOffset.x;
        this.y += positionOffset.y;
    }

    override function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(anim, force, reversed, frame);
        specialAnim = false;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        script.update(elapsed);

        if(heyTimer > 0)
        {
            heyTimer -= elapsed;
            if(heyTimer <= 0)
            {
                if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
                {
                    specialAnim = false;
                    dance();
                }
                heyTimer = 0;
            }
        } else if(specialAnim && animation.curAnim.finished)
        {
            specialAnim = false;
            dance();
        }

		if(!isPlayer)
		{            
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

        if (isLikeGF && canDance && animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
            playAnim('danceRight');
        
        script.callFunction("updatePost", [elapsed]);
    }

    var danced:Bool = false;

    public function dance()
    {
        if(isLikeGF)
        {
            if(canDance)
            {
                if(animation.curAnim != null && (animation.curAnim.name != "hairBlow" || animation.curAnim.name != "hairFall"))
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