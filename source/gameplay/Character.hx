package gameplay;

import haxe.Json;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import hscript.HScript;
import sys.FileSystem;
import systems.Conductor;
import systems.FNFSprite;

using StringTools;

typedef PsychCharacter = {
    var animations:Array<PsychCharacterAnimation>;
    var no_antialiasing:Bool;
    var image:String;
    var position:Array<Float>;
    var healthicon:String;
    var flip_x:Bool;
    var healthbar_colors:Array<Int>; // psych colors work with rgb
    var camera_position:Array<Float>;
    var sing_duration:Float;
    var scale:Float;
};

typedef PsychCharacterAnimation = {
    var offsets:Array<Float>;
    var loop:Bool;
    var anim:String;
    var fps:Int;
    var name:String;
    var indices:Array<Int>;
};

class Character extends FNFSprite {
    public var script:HScript;
    public var curCharacter:String = "bf";
    public var deathCharacter:String = "bf-dead";

    public var healthIcon:String = "face";

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

    public var healthBarColor:FlxColor = FlxColor.BLACK;

    public function new(x:Float, y:Float, char:String, isPlayer:Bool = false)
    {
        super(x, y);

        antialiasing = Init.trueSettings.get("Antialiasing");
        
        this.isPlayer = isPlayer;
        curCharacter = char;

        var path:String = 'characters/$char/script';
        if(!FileSystem.exists(AssetPaths.hxs(path)))
        {
            curCharacter = "bf";
            path = 'characters/bf/script';
        }

        script = new HScript(path);
        script.set("character", this);
        script.start();

        this.x += positionOffset.x;
        this.y += positionOffset.y;

        ogPosition = new FlxPoint(x, y);

        script.callFunction("createPost");
    }

    public function loadPsychJSON()
    {
        var path:String = 'characters/$curCharacter/config';
        if(FileSystem.exists(AssetPaths.json(path)))
        {
            var json:PsychCharacter = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json(path)));
            for(anim in json.animations)
            {
                if(anim.indices != null && anim.indices.length > 0)
                    animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
                else
                    animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

                setOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
            }

            healthIcon = json.healthicon;
            healthBarColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
            antialiasing = json.no_antialiasing ? false : Init.trueSettings.get("Antialiasing");
            flipX = json.flip_x;

            singDuration = json.sing_duration;
            scale.set(json.scale, json.scale);
            updateHitbox();

            positionOffset.set(json.position[0], json.position[1]);
            cameraPosition.set(json.camera_position[0], json.camera_position[1]);

            isLikeGF = animation.exists("danceLeft") && animation.exists("danceRight");

            dance();
        }
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

        if(animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
            playAnim(animation.curAnim.name + '-loop');

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