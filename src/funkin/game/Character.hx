package funkin.game;

import haxe.xml.Access;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import funkin.system.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Character extends FNFSprite {
	/**
	 * The name of the currently loaded character.
	 */
	public var curCharacter:String = "";

	/**
	 * The character to load when you lose all of your health.
	 */
	public var deathCharacter:String = "bf-dead";

	/**
	 * The icon used for the health bar.
	 */
	public var healthIcon:String = "face";

	/**
	 * The color used for the left or right sides of the health bar.
	 */
	public var healthBarColor:FlxColor = FlxColor.BLACK;

	public var curDanceStep:Int = 0;

	/**
	 * Allows you to have multiple animations when the character dances.
	 */
	public var danceSteps:Array<String> = ["idle"];

	/**
	 * Controls if the character can dance or not.
	 */
	public var canDance:Bool = true;

	/**
	 * Controls if the character acts like Boyfriend (Like only going back to idle when you release a note)
	 */
	public var isPlayer:Bool = false;

	/**
	 * Controls how long the character can hold down a note for before going back to idle.
	 */
	public var singDuration:Float = 4;

	public var animTimer:Float = 0;
	public var holdTimer:Float = 0.0;

	public var specialAnim:Bool = false;
	public var debugMode:Bool = false;

	public var stunned:Bool = false;
	public var initialized:Bool = false;

	/**
		The X and Y offset of this character's camera position.
	**/
	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);

	/**
		The X and Y offset of this character's position.
	**/
	public var positionOffset:FlxPoint = new FlxPoint(0, 0);

	/**
		The character's original scale from when it was loaded.
	**/
	public var ogScale:FlxPoint = new FlxPoint(0, 0);

	public var playerOffsets:Bool = false;

	var __baseFlipped:Bool = false;

	public function new(x:Float, y:Float, ?isPlayer:Bool = false) {
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public function getSingAnim(keyAmount:Int = 4, direction:Int = 0) {
		var dir:String = Note.keyInfo[keyAmount].directions[direction].toUpperCase();
		switch(dir) {
			case "MIDDLE":
				dir = "UP";
		}
		return "sing"+dir;
	}

	public function loadCharacter(name:String) {
		curCharacter = name;

		while(true) {
			switch (name) {
				// case "your-char": if you wanna hardcode
				default:
					// Load the intial XML Data.
					var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/characters/$name/config'))).firstElement();
					if(xml == null) {
						Console.error('Occured on character: $name | Either the XML doesn\'t exist or the "character" node is missing!');
						break;
					}
					var data:Access = new Access(xml);

					var atlasType:String = "SPARROW";
					if(data.has.atlasType) atlasType = data.att.atlasType;
					switch(atlasType.toLowerCase()) {
						case "packer":
							frames = Assets.load(PACKER, Paths.image('data/characters/$curCharacter/${data.att.spritesheet}', false));
						default:
							frames = Assets.load(SPARROW, Paths.image('data/characters/$curCharacter/${data.att.spritesheet}', false));
					}
					antialiasing = data.att.antialiasing == 'true' ? PlayerSettings.prefs.get("Antialiasing") : false;
					singDuration = Std.parseFloat(data.att.sing_duration);
					healthIcon = data.att.icon;
					flipX = data.att.flip_x == "true";
					playerOffsets = data.has.is_player && data.att.is_player == "true";

					deathCharacter = data.has.death_character ? data.att.death_character : "bf-dead";

					// Load animations
					var animations_node:Access = data.node.animations; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

					for (anim in animations_node.nodes.animation) {
						// Add the animation
						if (anim.has.indices && anim.att.indices.split(",").length > 1)
							animation.addByIndices(anim.att.name, anim.att.anim, CoolUtil.splitInt(anim.att.indices, ","), "", Std.parseInt(anim.att.fps),
								anim.att.looped == "true");
						else
							animation.addByPrefix(anim.att.name, anim.att.anim, Std.parseInt(anim.att.fps), anim.att.looped == "true");

						setOffset(anim.att.name, -Std.parseFloat(anim.att.offsetX), -Std.parseFloat(anim.att.offsetY));
					}

					// Load miscellaneous attributes

					// Create variables for cleaner code first
					var global_pos:Access = data.node.global_pos;
					var scale:Access = data.node.scale;
					var scroll:Access = data.node.scroll;
					var icon_color:Access = data.node.color;
					var camera:Access = data.node.camera;

					// Set the actual properties
					positionOffset.set(Std.parseFloat(global_pos.att.offsetX), Std.parseFloat(global_pos.att.offsetY));
					cameraOffset.set(Std.parseFloat(camera.att.offsetX), Std.parseFloat(camera.att.offsetY));

					this.scale.set(Std.parseFloat(scale.att.x), Std.parseFloat(scale.att.y));
					ogScale.set(this.scale.x, this.scale.y);
					updateHitbox();

					scrollFactor.set(Std.parseFloat(scroll.att.x), Std.parseFloat(scroll.att.y));

					if (icon_color.has.hex && icon_color.att.hex != "")
						healthBarColor = FlxColor.fromString(icon_color.att.hex);
					else
						healthBarColor = FlxColor.fromRGB(Std.parseInt(icon_color.att.r), Std.parseInt(icon_color.att.g), Std.parseInt(icon_color.att.b));

					// Dance Steps moment
					danceSteps = data.att.dance_steps.split(",");
					for (i in 0...danceSteps.length) danceSteps[i] = danceSteps[i].trim();
			}
			break;
		}

		if (isPlayer != playerOffsets) {
			// Swap left and right animations
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));

			// Swap left and right animations
			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		if (isPlayer)
			flipX = !flipX;
		__baseFlipped = flipX;
		dance();

		return this;
	}

	public function switchOffset(anim1:String, anim2:String) {
		if(!animation.exists(anim1) || !animation.exists(anim2)) return;
		var old = offsets[anim1];
		offsets[anim1] = offsets[anim2];
		offsets[anim2] = old;
	}

	public function getCameraPosition() {
		var midpoint = getMidpoint();
		return new FlxPoint(midpoint.x
			+ (isPlayer ? -100 : 150)
			+ positionOffset.x
			+ cameraOffset.x, midpoint.y
			- 100
			+ positionOffset.y
			+ cameraOffset.y);
	}

	// VVV CODE FROM CODENAME ENGINE!!!
	// I HAVE NO IDEA WHAT IT DOES OTHER THAN CORRECTING PLAYER OFFSETS!!!
	var __reverseDrawProcedure:Bool = false;

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__reverseDrawProcedure) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	public override function draw() {
		if ((isPlayer != playerOffsets) != (flipX != __baseFlipped)) {
			__reverseDrawProcedure = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		} else
			super.draw();
	}
	// YOSHICRAFTER29 MADE THIS 🙏
	// ^^^

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (animTimer > 0) {
			animTimer -= elapsed;
			if (animTimer <= 0) {
				if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer') {
					specialAnim = false;
					dance();
				}
				animTimer = 0;
			}
		}
		else if (specialAnim && animation.curAnim.finished) {
			specialAnim = false;
			dance();
		}

		if (!isPlayer) {
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed * FlxG.sound.music.pitch;

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.0011) {
				dance();
				holdTimer = 0;
			}
		} else {
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed * FlxG.sound.music.pitch;
			else
				holdTimer = 0;

			if (animation.curAnim != null && animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				playAnim('idle', true, false, 10);
		}

		if(animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
			playAnim(animation.curAnim.name + '-loop');

		if (danceSteps.length > 1 && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim(danceSteps[1]);
	}

	override function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);

		specialAnim = false;

		var daOffset = offsets.get(anim);
		if (daOffset != null)
			rotOffset.set(daOffset.x, daOffset.y);
		else
			rotOffset.set(0, 0);

		offset.set(positionOffset.x * (isPlayer != playerOffsets ? 1 : -1), -positionOffset.y);
	}

	var danced:Bool = false;

	public function dance() {
		if (specialAnim || !canDance) return;
		if ((animation.curAnim != null && !animation.curAnim.name.startsWith("hair")) || animation.curAnim == null) {
			danced = !danced;

			if (danceSteps.length > 1) {
				if (curDanceStep > danceSteps.length - 1) curDanceStep = 0;
				playAnim(danceSteps[curDanceStep]);
				curDanceStep++;
			} else {
				playAnim(danceSteps[0]);
			}
		}
	}
}