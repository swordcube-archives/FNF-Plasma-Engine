package gameplay;

import flixel.addons.effects.FlxTrail;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import haxe.Json;
import hscript.HScript;
import sys.FileSystem;
import systems.Conductor;
import systems.FNFSprite;

using StringTools;

// psych

typedef PsychCharacter =
{
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

typedef PsychCharacterAnimation =
{
	var offsets:Array<Float>;
	var loop:Bool;
	var anim:String;
	var fps:Int;
	var name:String;
	var indices:Null<Array<Int>>;
};

// leather

typedef LeatherCharacterConfig =
{
	var imagePath:String;
	var animations:Array<LeatherCharacterAnimation>;
	var defaultFlipX:Bool;
	var dancesLeftAndRight:Bool;
	var graphicsSize:Null<Float>;
	var graphicSize:Null<Float>;
	var barColor:Array<Int>;
	var positionOffset:Array<Float>;
	var cameraOffset:Array<Float>;

	var offsetsFlipWhenPlayer:Null<Bool>;
	var offsetsFlipWhenEnemy:Null<Bool>;

	var swapDirectionSingWhenPlayer:Null<Bool>;

	var trail:Null<Bool>;
	var trailLength:Null<Int>;
	var trailDelay:Null<Int>;
	var trailStalpha:Null<Float>;
	var trailDiff:Null<Float>;

	var deathCharacter:Null<String>;
	var deathCharacterName:Null<String>;

	// multiple characters stuff

	var healthIcon:String;
	var antialiased:Null<Bool>;
};

typedef LeatherCharacterAnimation =
{
	var name:String;
	var animation_name:String;
	var indices:Null<Array<Int>>;
	var fps:Int;
	var looped:Bool;
};

// yoshi

typedef YoshiCharacter =
{
    var arrowColors:Array<String>; // Unused
    var camOffset:YoshiCharPosShit;
    var globalOffset:YoshiCharPosShit;
    var healthbarColor:String;
    var flipX:Bool;
    var anims:Array<YoshiCharacterAnimation>;
    var danceSteps:Array<String>;
    var antialiasing:Bool;
    var healthIconSteps:Array<Array<Int>>; // I don't know exactly what this does, but it's gonna go unused because
    // the way health icons work in plasma is different from yoshi
    var scale:Float;
};

typedef YoshiCharPosShit = 
{
    var x:Float;
    var y:Float;
};

typedef YoshiCharacterAnimation =
{
    var indices:Null<Array<Int>>;
	var x:Float;
    var y:Float;
    var anim:String;
	var loop:Bool;
	var name:String;
	var framerate:Int;
};

class Character extends FNFSprite
{
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

	public var trail:FlxTrail;

	public function new(x:Float, y:Float, char:String, isPlayer:Bool = false)
	{
		super(x, y);

		antialiasing = Init.trueSettings.get("Antialiasing");

		this.isPlayer = isPlayer;
		curCharacter = char;

		var path:String = 'characters/$char/script';
		if (!FileSystem.exists(AssetPaths.hxs(path)))
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

		script.call("createPost");
	}

	public function loadPsychJSON()
	{
		var path:String = 'characters/$curCharacter/config';
		if (FileSystem.exists(AssetPaths.json(path)))
		{
			var json:PsychCharacter = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json(path)));
			for (anim in json.animations)
			{
				if (anim.indices != null && anim.indices.length > 0)
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

    public function loadYoshiJSON()
    {
		var path:String = 'characters/$curCharacter/config';
		if (FileSystem.exists(AssetPaths.json(path)))
		{
            var json:YoshiCharacter = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json(path)));
            cameraPosition.set(json.camOffset.x, json.camOffset.y);
            positionOffset.set(json.globalOffset.x, json.globalOffset.y);

            healthIcon = curCharacter;
            healthBarColor = FlxColor.fromString(json.healthbarColor);
            flipX = json.flipX;

            for(anim in json.anims)
            {
                if(anim.indices != null && anim.indices.length > 0)
                    animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
                else
                    animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

                setOffset(anim.name, anim.x, anim.y);
            }

            isLikeGF = json.danceSteps.contains("danceLeft") && json.danceSteps.contains("danceRight");
            antialiasing = json.antialiasing ? Init.trueSettings.get("Antialiasing") : false;

            scale.set(json.scale, json.scale);
            updateHitbox();

            dance();
        }
    }

	public function loadLeatherJSON()
	{
		var path:String = 'characters/$curCharacter/';

		if (FileSystem.exists(AssetPaths.json('${path}config')))
		{
			var config:LeatherCharacterConfig = cast Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('${path}config')));

			if(!isPlayer)
				flipX = config.defaultFlipX;
			else
				flipX = !config.defaultFlipX;

			isLikeGF = config.dancesLeftAndRight;

			if(FileSystem.exists(AssetPaths.txt('${path}${config.imagePath}')))
				frames = FNFAssets.returnAsset(PACKER, '../${path}${config.imagePath}');
			//else if(FileSystem.exists(AssetPaths.json("images/characters/" + config.imagePath + "/Animation.json", TEXT, "shared")))
			//	frames = AtlasFrameMaker.construct("characters/" + config.imagePath);
			else
				frames = FNFAssets.returnAsset(SPARROW, '../${path}${config.imagePath}');

			var size:Null<Float> = config.graphicSize;

			if(size == null)
				size = config.graphicsSize;

			if(size != null)
				scale.set(size, size);

			for(selected_animation in config.animations)
			{
				if(selected_animation.indices != null && selected_animation.indices.length > 0)
				{
					animation.addByIndices(
						selected_animation.name,
						selected_animation.animation_name,
						selected_animation.indices, "",
						selected_animation.fps,
						selected_animation.looped
					);
				}
				else
				{
					animation.addByPrefix(
						selected_animation.name,
						selected_animation.animation_name,
						selected_animation.fps,
						selected_animation.looped
					);
				}
			}

			if(animation.exists("firstDeath"))
				playAnim("firstDeath");
			else
			{
				if(isLikeGF)
					playAnim("danceRight");
				else
					playAnim("idle");
			}

			if(debugMode)
				flipX = config.defaultFlipX;
		
			if(config.antialiased != null)
				antialiasing = config.antialiased;

			updateHitbox();

			if(config.positionOffset != null)
				positionOffset.set(config.positionOffset[0], config.positionOffset[1]);

			if(config.trail == true)
				trail = new FlxTrail(this, null, config.trailLength, config.trailDelay, config.trailStalpha, config.trailDiff);

			if(config.barColor == null)
				config.barColor = [255, 0, 0];
	
			healthBarColor = FlxColor.fromRGB(config.barColor[0], config.barColor[1], config.barColor[2]);
	
			if(config.cameraOffset != null)
			{
				if(flipX)
					config.cameraOffset[0] = 0 - config.cameraOffset[0];
	
				cameraPosition.add(config.cameraOffset[0], config.cameraOffset[1]);
			}
	
			if(config.deathCharacter != null)
				deathCharacter = config.deathCharacter;
			else if(config.deathCharacterName != null)
				deathCharacter = config.deathCharacterName;
			else
				deathCharacter = "bf-dead";
	
			if(config.healthIcon != null)
				healthIcon = config.healthIcon;
			else
				healthIcon = curCharacter;

			var offset_text:String = FNFAssets.returnAsset(TEXT, AssetPaths.txt('${path}offsets'));
			var offsets_string_array:Array<String> = offset_text.trim().split("\n");
			
			for (offset_string in offsets_string_array)
			{
				var offset_data:Array<String> = offset_string.split(" ");
				setOffset(offset_data[0], Std.parseFloat(offset_data[1]), Std.parseFloat(offset_data[2]));
			}
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

		if (heyTimer > 0)
		{
			heyTimer -= elapsed;
			if (heyTimer <= 0)
			{
				if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if (specialAnim && animation.curAnim.finished)
		{
			specialAnim = false;
			dance();
		}

		if (!isPlayer)
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
			playAnim(animation.curAnim.name + '-loop');

		if (isLikeGF && canDance && animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		script.call("updatePost", [elapsed]);
	}

	var danced:Bool = false;

	public function dance()
	{
		if (isLikeGF)
		{
			if (canDance)
			{
				if (animation.curAnim != null && (animation.curAnim.name != "hairBlow" || animation.curAnim.name != "hairFall"))
				{
					danced = !danced;
					if (danced)
						playAnim("danceRight");
					else
						playAnim("danceLeft");
				}
			}
		}
		else
		{
			if (canDance)
				playAnim("idle");
		}
	}
}
