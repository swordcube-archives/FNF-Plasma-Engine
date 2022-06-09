package funkin;

import base.Conductor;
import base.CoolUtil;
import haxe.Json;
import hscript.HScript;
import states.PlayState;

using StringTools;

// GE Character Type

typedef CharacterData = {
	var animations:Array<CharacterAnim>;
	var healthIcon:String;
	var healthBarColor:String;
	var antiAliasing:Bool;
	var singDuration:Float;
	var flipX:Bool;
	var scale:Float;
	var position:Array<Float>;
	var cameraPosition:Array<Float>;
	var deathCharacter:String;
};

typedef CharacterAnim = {
	var animName:String;
	var animPrefix:String;
	var animOffsets:Array<Float>;
	var animIndices:Array<Int>;
	var fps:Int;
	var looped:Bool;
};

// Psych Character Type
typedef PsychCharacter = {
	var animations:Array<PsychCharacterAnim>;
	var no_antialiasing:Bool;
	var image:String;
	var position:Array<Float>;
	var healthicon:String;
	var flip_x:Bool;
	var healthbar_colors:Array<Int>;
	var camera_position:Array<Float>;
	var sing_duration:Float;
	var scale:Float;
	var deathCharacter:String;
};

typedef PsychCharacterAnim = {
	var offsets:Array<Float>;
	var loop:Bool;
	var fps:Int;
	var anim:String; // anim name
	var indices:Array<Int>;
	var name:String; // anim prefix
};

class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var healthIcon:String = 'face';
	public var healthBarColor:String = '#000000';

	public var deathCharacter:String = 'bf-dead';

	public var json:CharacterData;

	public var singDuration:Float = 0;
	public var holdTimer:Float = 0;

	public var gfLikeCharacters:Array<String> = [
		"gf",
		"spooky"
	];

	public var cameraPosition:Array<Float> = [
		0,
		0
	];

	public var script:HScript;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		// Switch case is here if you wanna hardcode your character
		// For whatever reason
		switch(curCharacter)
		{
			default:
				var readJson:Dynamic = Json.parse(GenesisAssets.getAsset('images/characters/jsons/$curCharacter.json', TEXT));
				
				if(readJson.image != null) // Checks if the char is a Psych one then does some cool magic
				{
					var psychJson:PsychCharacter = readJson;

					var deathCharacter:String = "bf-dead";
					if(psychJson.deathCharacter != null)
						deathCharacter = psychJson.deathCharacter;
					
					// Convert everything (except anims) in a psych json to
					// GE format, We convert anims after setting the json here
					json = {
						"animations": [],
						"healthIcon": psychJson.healthicon,
						"healthBarColor": CoolUtil.rgbToHex(psychJson.healthbar_colors[0], psychJson.healthbar_colors[1], psychJson.healthbar_colors[2]),
						"antiAliasing": !psychJson.no_antialiasing,
						"singDuration": psychJson.sing_duration,
						"flipX": psychJson.flip_x,
						"scale": psychJson.scale,
						"position": psychJson.position,
						"cameraPosition": psychJson.camera_position,
						"deathCharacter": deathCharacter
					};

					// Convert the animations to GE format
					for(psychAnim in psychJson.animations)
					{
						json.animations.push({
							"animName": psychAnim.anim,
							"animPrefix": psychAnim.name,
							"animOffsets": psychAnim.offsets,
							"animIndices": psychAnim.indices,
							"looped": psychAnim.loop,
							"fps": psychAnim.fps
						});
					}
				}
				else
					json = readJson; // If it's a GE json then we don't need to convert anything.

				singDuration = json.singDuration;
				deathCharacter = json.deathCharacter;

				frames = GenesisAssets.getAsset('characters/spritesheets/$curCharacter/assets', SPARROW);

				var anims:Array<Dynamic> = json.animations;

				for(anim in anims)
				{
					if(anim.animIndices != null && anim.animIndices.length > 0)
						animation.addByIndices(anim.animName, anim.animPrefix, anim.animIndices, '', anim.fps, anim.looped);
					else
						animation.addByPrefix(anim.animName, anim.animPrefix, anim.fps, anim.looped);

					addOffset(anim.animName, anim.animOffsets[0], anim.animOffsets[1]);
				}

				if(json.antiAliasing)
					antialiasing = Init.getOption('anti-aliasing');
				else
					antialiasing = false;

				flipX = json.flipX;

				scale.set(json.scale, json.scale);
				updateHitbox();

				this.x += json.position[0];
				this.y += json.position[1];

				cameraPosition = json.cameraPosition;
				healthIcon = json.healthIcon;
				healthBarColor = json.healthBarColor;
		}

		
		if(GenesisAssets.exists('images/characters/scripts/$curCharacter/script.hx', HSCRIPT))
		{
			script = new HScript('images/characters/scripts/$curCharacter/script.hx');
			script.state = PlayState.instance;
			script.start();
			
			script.callFunction("createCharacter", [curCharacter, isPlayer]);

			PlayState.instance.scripts.push(script);
		}

		dance();
		animation.finish();
    }

	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	
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

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				{
					danced = true;
					playAnim('danceRight');
				}
			case 'pico-speaker':
				/*if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					//trace("played shoot anim" + animationNotes[0][1]);
					var shotDirection:Int = 1;
					if (animationNotes[0][1] >= 2)
					{
						shotDirection = 3;
					}
					shotDirection += FlxG.random.int(0, 1);
					
					playAnim('shoot' + shotDirection, true);
					animationNotes.shift();
				}
				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
				}*/
		}

		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
			{
				dance();
				holdTimer = 0;
			}
		}

		if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			playAnim(animation.curAnim.name + '-loop');
	}

	public var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'pico-speaker':
					// do nothing LOL
				case 'tankman':
					if (!animation.curAnim.name.endsWith('DOWN-alt'))
						playAnim('idle');
				default:
					if(animOffsets.exists('danceLeft') && animOffsets.exists('danceRight'))
					{
						if(animation.curAnim == null || !animation.curAnim.name.startsWith('hair'))
						{
							danced = !danced;

							if(animation.curAnim != null && animation.curAnim.name == "singLEFT")
								danced = false;

							if(animation.curAnim != null && animation.curAnim.name == "singRIGHT")
								danced = true;
		
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
	}
}