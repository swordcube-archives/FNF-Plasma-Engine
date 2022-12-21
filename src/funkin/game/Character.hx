package funkin.game;

import flixel.addons.effects.FlxTrail;
import funkin.scripting.Script;
import haxe.xml.Access;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import funkin.system.FNFSprite;
import flixel.FlxG;

using StringTools;

// Typedefs
// Psych

@:dox(hide)
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

@:dox(hide)
typedef PsychCharacterAnimation = {
	var offsets:Array<Float>;
	var loop:Bool;
	var anim:String;
	var fps:Int;
	var name:String;
	var indices:Null<Array<Int>>;
};

// Yoshi

@:dox(hide)
typedef YoshiCharacter = {
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

@:dox(hide)
typedef YoshiCharPosShit = {
	var x:Float;
	var y:Float;
};

@:dox(hide)
typedef YoshiCharacterAnimation = {
	var indices:Null<Array<Int>>;
	var x:Float;
	var y:Float;
	var anim:String;
	var loop:Bool;
	var name:String;
	var framerate:Int;
};

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

	public var isTruePlayer:Bool = false;

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

	/**
	 * The trail that goes behind this character.
	 */
	public var trail:FlxTrail;

	public var playerOffsets:Bool = false;

	/**
	 * The character's script.
	 */
	public var script:ScriptModule;

	var __baseFlipped:Bool = false;
	var __antialiasing:Bool = true;

	public var specialAnims:Array<String> = [];

	public function new(?x:Float = 0, ?y:Float = 0, ?isPlayer:Bool = false) {
		super(x, y);
		this.isPlayer = isPlayer;
	}

	/**
	 * Returns if a character exists.
	 * @param name The character to check.
	 */
	public static function charExists(name:String, ?mod:Null<String>) {
		return FileSystem.exists(Paths.asset('data/characters/$name', mod));
	}

	/**
	 * Preloads a character called `name`.
	 * @param name The character to preload.
	 */
	public static function preloadCharacter(name:String) {
		var cachedGuyPerson = new Character(0, 0, false).loadCharacter(name);
		FlxG.state.add(cachedGuyPerson);
		cachedGuyPerson.destroy();
	}

	public function getSingAnim(keyAmount:Int = 4, direction:Int = 0) {
		var dir:String = Note.keyInfo[keyAmount].directions[direction].toUpperCase();
		switch (dir) {
			case "MIDDLE":
				dir = "UP";
		}
		return "sing" + dir;
	}

	public function loadCharacter(name:String) {
		curCharacter = name;

		// Loading the character's script
		if (script != null) {
			script.destroy();
			script = null;
		}
		script = Script.load(Paths.script('data/characters/$curCharacter/script'));
		script.set("character", this);
		script.run();

		// Player offset shit, don't worry bout it
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

		Conductor.onStep.add(stepHit);

		return this;
	}

	// i have this so people can port characters from psych
	// to plasma easier
	// don't murder me
	// thanks
	public function loadPsych(?mod:Null<String>) {
		// Error handling
		var jsonPath:String = Paths.json('data/characters/$curCharacter/config', mod);
		if (!FileSystem.exists(jsonPath))
			return Console.error('Occured on character: $curCharacter | The JSON config file doesn\'t exist!');

		// JSON Data
		var data:PsychCharacter = Assets.load(JSON, jsonPath);

		// Loading frames
		var spritesheetPath:String = 'data/characters/$curCharacter/spritesheet';
		var xmlPath:String = Paths.xml(spritesheetPath, mod);
		if (FileSystem.exists(xmlPath))
			load(SPARROW, Paths.image(spritesheetPath, false, mod));
		else
			load(PACKER, Paths.image(spritesheetPath, false, mod));

		antialiasing = !data.no_antialiasing ? PlayerSettings.prefs.get("Antialiasing") : false;
		__antialiasing = !data.no_antialiasing;
		singDuration = data.sing_duration;
		healthIcon = data.healthicon;
		flipX = data.flip_x;
		playerOffsets = isPlayer;
		isTruePlayer = false;

		deathCharacter = curCharacter + "-dead";
		if (!charExists(deathCharacter))
			deathCharacter = "bf-dead";

		for (anim in data.animations) {
			if (anim.indices != null && anim.indices.length > 1)
				animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
			else
				animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

			setOffset(anim.anim, -anim.offsets[0], -anim.offsets[1]);
		}

		positionOffset.set(data.position[0], data.position[1]);
		cameraOffset.set(data.camera_position[0], data.camera_position[1]);

		this.scale.set(data.scale, data.scale);
		ogScale.set(this.scale.x, this.scale.y);
		updateHitbox();

		scrollFactor.set(1, 1);

		var rgb:Array<Int> = data.healthbar_colors;
		healthBarColor = FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);

		// Dance Steps moment
		danceSteps = (animation.exists("danceLeft") && animation.exists("danceRight")) ? ["danceLeft", "danceRight"] : ["idle"];
	}

	public function loadYoshi(?mod:Null<String>) {
		// Error handling
		var jsonPath:String = Paths.json('data/characters/$curCharacter/config', mod);
		if (!FileSystem.exists(jsonPath))
			return Console.error('Occured on character: $curCharacter | The JSON config file doesn\'t exist!');

		// JSON Data
		var data:YoshiCharacter = Assets.load(JSON, jsonPath);

		// Loading frames
		var spritesheetPath:String = 'data/characters/$curCharacter/spritesheet';
		var xmlPath:String = Paths.xml(spritesheetPath, mod);
		if (FileSystem.exists(xmlPath))
			load(SPARROW, Paths.image(spritesheetPath, false, mod));
		else
			load(PACKER, Paths.image(spritesheetPath, false, mod));

		antialiasing = data.antialiasing ? PlayerSettings.prefs.get("Antialiasing") : false;
		__antialiasing = data.antialiasing;
		singDuration = 4;
		healthIcon = curCharacter;
		flipX = data.flipX;
		playerOffsets = isPlayer;
		isTruePlayer = false;

		deathCharacter = curCharacter + "-dead";
		if (!charExists(deathCharacter))
			deathCharacter = "bf-dead";

		for (anim in data.anims) {
			if (anim.indices != null && anim.indices.length > 1)
				animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
			else
				animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

			setOffset(anim.name, -anim.x, -anim.y);
		}

		positionOffset.set(data.globalOffset.x, data.globalOffset.y);
		cameraOffset.set(data.camOffset.x, data.camOffset.y);

		this.scale.set(data.scale, data.scale);
		ogScale.set(this.scale.x, this.scale.y);
		updateHitbox();

		scrollFactor.set(1, 1);

		healthBarColor = FlxColor.fromString(data.healthbarColor);

		// Dance Steps moment
		danceSteps = (data.danceSteps != null && data.danceSteps.length > 1) ? data.danceSteps : ["idle"];
	}

	public function loadXML(?mod:Null<String>) {
		// Load the intial XML Data.
		var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/characters/$curCharacter/config', mod))).firstElement();
		if (xml == null)
			return Console.error('Occured on character: $curCharacter | Either the XML doesn\'t exist or the "character" node is missing!');

		var data:Access = new Access(xml);

		var atlasType:String = "SPARROW";
		if (data.has.atlasType)
			atlasType = data.att.atlasType;
		var spritesheetName:String = data.has.spritesheet ? data.att.spritesheet : "spritesheet";
		switch (atlasType.toLowerCase()) {
			case "packer":
				load(PACKER, Paths.image('data/characters/$curCharacter/$spritesheetName', false, mod));
			default:
				load(SPARROW, Paths.image('data/characters/$curCharacter/$spritesheetName', false, mod));
		}
		antialiasing = data.has.antialiasing ? (data.att.antialiasing == 'true' ? PlayerSettings.prefs.get("Antialiasing") : false) : PlayerSettings.prefs.get("Antialiasing");
		__antialiasing = data.has.antialiasing ? data.att.antialiasing == 'true' : true;
		singDuration = data.has.sing_duration ? Std.parseFloat(data.att.sing_duration) : 4.0;
		healthIcon = data.has.icon ? data.att.icon : curCharacter;
		flipX = data.att.flip_x == "true";
		playerOffsets = data.has.is_player && data.att.is_player == "true";
		isTruePlayer = playerOffsets;

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

			if (anim.has.specialAnim && anim.att.specialAnim == "true")
				specialAnims.push(anim.att.name);

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
		danceSteps = data.has.dance_steps ? data.att.dance_steps.split(",") : ["idle"];
		for (i in 0...danceSteps.length)
			danceSteps[i] = danceSteps[i].trim();
	}

	public function switchOffset(anim1:String, anim2:String) {
		if (!animation.exists(anim1) || !animation.exists(anim2))
			return;
		var old = offsets[anim1];
		offsets[anim1] = offsets[anim2];
		offsets[anim2] = old;
	}

	public function getCameraPosition() {
		var midpoint = getMidpoint();
		return FlxPoint.get(midpoint.x
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

		script.updateCall(elapsed);

		if(!debugMode) {
			if (animTimer > 0) {
				animTimer -= elapsed;
				if (animTimer <= 0) {
					if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer') {
						specialAnim = false;
						dance();
					}
					animTimer = 0;
				}
			} else if (specialAnim && ((animation.curAnim != null && animation.curAnim.finished) || (animation.curAnim == null))) {
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

			if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
				playAnim(animation.curAnim.name + '-loop');

			if (danceSteps.length > 1 && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				playAnim(danceSteps[1]);
		}

		script.updatePostCall(elapsed);
	}

	override function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);

		if (animation.exists(anim) && offsets.exists(anim)) {
			specialAnim = specialAnims.contains(anim);

			var daOffset = offsets.get(anim);
			rotOffset.set(daOffset.x, daOffset.y);
		}

		offset.set(positionOffset.x * (isPlayer != playerOffsets ? 1 : -1), -positionOffset.y);
	}

	var danced:Bool = false;

	public function beatHit(beat:Int) {
		if(!alive) return;
		script.call("onBeatHit", [beat]);
		script.call("beatHit", [beat]);
		dance();
		script.call("onBeatHitPost", [beat]);
		script.call("beatHitPost", [beat]);
	}

	public function stepHit(step:Int) {
		if(!alive) return;
		script.call("onStepHit", [step]);
		script.call("stepHit", [step]);
		script.call("onStepHitPost", [step]);
		script.call("stepHitPost", [step]);
	}

	public function dance() {
		if (specialAnim || !canDance)
			return;
		if ((animation.curAnim != null && !animation.curAnim.name.startsWith("hair")) || animation.curAnim == null) {
			danced = !danced;

			if (danceSteps.length > 1) {
				if (curDanceStep > danceSteps.length - 1)
					curDanceStep = 0;
				playAnim(danceSteps[curDanceStep]);
				curDanceStep++;
			} else {
				if (danceSteps.length > 0)
					playAnim(danceSteps[0]);
			}
		}
	}

	override public function destroy() {
		Conductor.onStep.remove(stepHit);
		super.destroy();
	}
}
