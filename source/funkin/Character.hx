package funkin;

import base.Conductor;
import haxe.Json;
import hscript.HScript;
import states.PlayState;

using StringTools;

typedef CharacterData = {
	var animations:Array<CharacterAnimationData>;
	var healthIcon:String;
	var healthBarColor:String;
	var antiAliasing:Bool;
	var singDuration:Float;
	var flipX:Bool;
	var scale:Float;
	var position:Array<Float>;
	var cameraPosition:Array<Float>;
	var actsLike:String;
	var deathCharacter:String;
};

typedef CharacterAnimationData = {
	var animName:String;
	var animPrefix:String;
	var animOffsets:Array<Float>;
	var animIndices:Array<Int>;
	var fps:Int;
	var looped:Bool;
};

class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

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
				json = Json.parse(GenesisAssets.getAsset('images/characters/jsons/$curCharacter.json', TEXT));

				singDuration = json.singDuration;

				frames = GenesisAssets.getAsset('characters/spritesheets/$curCharacter/assets', SPARROW);

				for(anim in json.animations)
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

				x += json.position[0];
				y += json.position[1];

				cameraPosition = json.cameraPosition;
		}

		
		if(GenesisAssets.exists('images/characters/scripts/$curCharacter/script.hx', HSCRIPT))
		{
			script = new HScript('images/characters/scripts/$curCharacter/script.hx');
			script.callFunction("create", [curCharacter, isPlayer]);

			PlayState.instance.scripts.push(script);
		}

		dance();
		animation.finish();
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

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
					if(json.actsLike != null && gfLikeCharacters.contains(json.actsLike))
					{
						if(animation.curAnim == null || !animation.curAnim.name.startsWith('hair'))
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
	}
}