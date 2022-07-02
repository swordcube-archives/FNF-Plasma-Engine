package funkin.game;

import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.HScript;
import funkin.systems.Paths;

using StringTools;

class Character extends FunkinSprite
{
    public var singDuration:Float = 4.0;

    public var ogPos:Array<Float> = [0, 0];

    public var positionOffset:Array<Float> = [0, 0];
    public var cameraOffset:Array<Float> = [0, 0];

    public var curCharacter:String = "bf";

    public var isPlayer:Bool = false;
    public var debugMode:Bool = false;

    public var script:HScript;

    public var holdTimer:Float = 0;
    public var dancesLeftAndRight:Bool = false;

    public function new(x:Float, y:Float, char:String, isPlayer:Bool = false)
    {
        super(x, y);

        this.curCharacter = char;
        this.isPlayer = isPlayer;
        
        ogPos = [x, y];

        load();
    }

    public function load()
    {
        var charPath:String = Paths.characterHX(curCharacter);
        if(!FunkinAssets.exists(charPath))
        {
            curCharacter = "bf";
            charPath = Paths.characterHX("bf");
        }

        script = new HScript(charPath);
        script.interp.variables.set("character", this);
        script.start();
        PlayState.scripts.push(script);

        if(isPlayer)
            flipX = !flipX;
        
        trace(positionOffset);

        x += positionOffset[0];
        y += positionOffset[1];

        script.callFunction("createPost");
    }

	override function update(elapsed:Float)
	{
        script.update(elapsed);

		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		super.update(elapsed);

        script.callFunction("updatePost", [elapsed]);
	}

    var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			if(dancesLeftAndRight)
			{
                if (animation.curAnim == null || !animation.curAnim.name.startsWith('hair'))
                {
                    danced = !danced;

                    if (danced)
                        playAnim('danceRight');
                    else
                        playAnim('danceLeft');
                }
			}
            else
                playAnim('idle');
		}
	}

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		if (dancesLeftAndRight)
		{
			if (name == 'singLEFT')
				danced = true;
			else if (name == 'singRIGHT')
				danced = false;
		}
    }
}