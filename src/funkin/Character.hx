package funkin;

import scripting.HScriptModule;
import scripting.Script;
import scripting.ScriptModule;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import haxe.xml.Access;
import funkin.states.PlayState;

using StringTools;

// psych
#if docs @:noCompletion #end typedef PsychCharacter = {
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

#if docs @:noCompletion #end typedef PsychCharacterAnimation = {
	var offsets:Array<Float>;
	var loop:Bool;
	var anim:String;
	var fps:Int;
	var name:String;
	var indices:Null<Array<Int>>;
};

// leather

#if docs @:noCompletion #end typedef LeatherCharacterConfig = {
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

#if docs @:noCompletion #end typedef LeatherCharacterAnimation = {
	var name:String;
	var animation_name:String;
	var indices:Null<Array<Int>>;
	var fps:Int;
	var looped:Bool;
};

// yoshi

#if docs @:noCompletion #end typedef YoshiCharacter = {
	var arrowColors:Array<String>; // Unused
	var camOffset:BasicPoint;
	var globalOffset:BasicPoint;
	var healthbarColor:String;
	var flipX:Bool;
	var anims:Array<YoshiCharacterAnimation>;
	var danceSteps:Array<String>;
	var antialiasing:Bool;
	var scale:Float;
};

#if docs @:noCompletion #end typedef YoshiCharacterAnimation = {
	var indices:Null<Array<Int>>;
	var x:Float;
	var y:Float;
	var anim:String;
	var loop:Bool;
	var name:String;
	var framerate:Int;
};

/**
 * A character sprite for gameplay.
 */
class Character extends Sprite {
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

	/**
	 * When setting the X and Y of this character using `setPosition()`, it gets offset using this variable.
	 */
	public var positionOffset:FlxPoint = new FlxPoint();
	/**
	 * When the camera focuses on this character, it gets offset using this variable.
	 */
	public var cameraOffset:FlxPoint = new FlxPoint();
	public var ogPosition:FlxPoint = new FlxPoint();

	/**
	 * The trail behind this character.
	 */
	public var trail:FlxTrail;

	/**
	 * The script that this character loads.
	 */
	public var script:ScriptModule;

	/**
	 * Prevents this character from hitting notes.
	 */
	public var stunned:Bool = false;

	public var initialized:Bool = false;

	public function new(x:Float, y:Float, isPlayer:Bool = false) {
		super(x, y);
		this.isPlayer = isPlayer;
		ogPosition = new FlxPoint(x, y);
	}

	/**
	 * Preloads a character with the name of `character`.
	 * @param character The character to preload.
	 * @param mod The mod to preload from.
	 */
	public static function preloadCharacter(character:String, ?mod:Null<String>) {
		new HealthIcon().loadIcon(character);
		return new Character(0,0,false).loadCharacter(character);
	}

	/**
	 * Loads the character with the name of `character`.
	 * @param character The character to load.
	 * @param mod The mod to load from.
	 */
	public function loadCharacter(character:String, ?mod:Null<String>) {
		this.curCharacter = character;

		if (script != null)
			script.destroy();

		script = Script.create(Paths.script('data/characters/$character/script', mod));
		if (Std.isOfType(script, HScriptModule)) {
			script.set("mod", mod);
			script.set("character", this);
			cast(script, HScriptModule).setScriptObject(this);
		} else {
			script.destroy();
			script = Script.create(Paths.script('data/characters/template/script', mod));
			if (Std.isOfType(script, HScriptModule)) {
				script.set("mod", mod);
				script.set("character", this);
				cast(script, HScriptModule).setScriptObject(this);
			}
			this.curCharacter = "template";
		}
		script.start(true, []);
		if (animation.curAnim == null)
			dance();

		if (isPlayer && !initialized)
			flipX = !flipX;

		initialized = true;

		this.x = ogPosition.x + positionOffset.x;
		this.y = ogPosition.y + positionOffset.y;

		return this;
	}

	/**
	 * Sets the X and Y of this character to `x` and `y` with an offset of `positionOffset`'s x and y.
	 * @param x The X to apply.
	 * @param y The Y to apply.
	 */
	override public function setPosition(x:Float = 0, y:Float = 0) {
		super.setPosition(x, y);
		ogPosition = new FlxPoint(x, y);
		this.x += positionOffset.x;
		this.y += positionOffset.y;
	}

	/**
	 * Gets the config XML from `mods/yourMod/data/characters/yourChar/config.xml` for this character and loads it.
	 * @param mod The mod to load from.
	 */
	public function loadPlasmaXML(?mod:Null<String>):Void {
		// Load the intial XML Data.
		var data:Access = new Access(Xml.parse(Assets.load(TEXT, Paths.xml('data/characters/$curCharacter/config', mod))).firstElement());

		// Load attributes from the 'character' node aka first element.
		frames = Assets.load(SPARROW, Paths.image('data/characters/$curCharacter/${data.att.spritesheet}', false, mod));
		antialiasing = data.att.antialiasing == 'true' ? Settings.get("Antialiasing") : false;
		singDuration = Std.parseFloat(data.att.sing_duration);
		healthIcon = data.att.icon;
		flipX = data.att.flip_x == "true";

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
		updateHitbox();

		// leather is based for adding this because gf in base game has 0.95 scroll factor
		// and also it's just nice to have this
		scrollFactor.set(Std.parseFloat(scroll.att.x), Std.parseFloat(scroll.att.y));

		if (icon_color.has.hex && icon_color.att.hex != "")
			healthBarColor = FlxColor.fromString(icon_color.att.hex);
		else
			healthBarColor = FlxColor.fromRGB(Std.parseInt(icon_color.att.r), Std.parseInt(icon_color.att.g), Std.parseInt(icon_color.att.b));

		// Dance Steps moment
		danceSteps = data.att.dance_steps.split(",");
		for (i in 0...danceSteps.length)
			danceSteps[i] = danceSteps[i].trim();
		if (!initialized)
			dance();

		if (isPlayer)
			flipX = !flipX;
		initialized = true;
	}

	/**
	 * Gets the config JSON from `mods/yourMod/data/characters/yourChar/config.json` for this character and loads it.
	 * 
	 * **This function is designed to load Psych Engine JSONs, If you need to load a Yoshi Engine JSON, use `loadYoshiJSON()`**
	 * @param mod The mod to load from.
	 */
	public function loadPsychJSON(?mod:Null<String>) {
		frames = Assets.load(SPARROW, Paths.image('data/characters/$curCharacter/spritesheet', false, mod));
		var path:String = 'data/characters/$curCharacter/config';
		if (FileSystem.exists(Paths.json(path))) {
			var json:PsychCharacter = tjson.TJSON.parse(Assets.load(TEXT, Paths.json(path, mod)));
			for (anim in json.animations) {
				if (anim.indices != null && anim.indices.length > 0)
					animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
				else
					animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

				setOffset(anim.anim, -anim.offsets[0], -anim.offsets[1]);
			}

			healthIcon = json.healthicon;
			healthBarColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
			antialiasing = json.no_antialiasing ? false : Settings.get("Antialiasing");
			flipX = json.flip_x;

			singDuration = json.sing_duration;
			scale.set(json.scale, json.scale);
			updateHitbox();

			positionOffset.set(json.position[0], json.position[1]);
			cameraOffset.set(json.camera_position[0], json.camera_position[1]);

			danceSteps = animation.exists("danceLeft") && animation.exists("danceRight") ? ["danceLeft", "danceRight"] : ["idle"];

			if (!initialized)
				dance();

			if (isPlayer)
				flipX = !flipX;
			initialized = true;
		}
	}

	/**
	 * Gets the config JSON from `mods/yourMod/data/characters/yourChar/config.json` for this character and loads it.
	 * 
	 * **This function is designed to load Yoshi Engine JSONs, If you need to load a Psych Engine JSON, use `loadPsychJSON()`**
	 * @param mod The mod to load from.
	 */
	public function loadYoshiJSON(?mod:Null<String>) {
		frames = Assets.load(SPARROW, Paths.image('characters/$curCharacter/spritesheet', false, mod));
		var path:String = 'data/characters/$curCharacter/config';
		if (FileSystem.exists(Paths.json(path))) {
			var json:YoshiCharacter = tjson.TJSON.parse(Assets.load(TEXT, Paths.json(path, mod)));
			cameraOffset.set(json.camOffset.x, json.camOffset.y);
			positionOffset.set(json.globalOffset.x, json.globalOffset.y);

			healthIcon = curCharacter;
			healthBarColor = FlxColor.fromString(json.healthbarColor);
			flipX = json.flipX;

			for (anim in json.anims) {
				if (anim.indices != null && anim.indices.length > 0)
					animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
				else
					animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

				setOffset(anim.name, -anim.x, -anim.y);
			}

			danceSteps = json.danceSteps;
			antialiasing = json.antialiasing ? Settings.get("Antialiasing") : false;

			scale.set(json.scale, json.scale);
			updateHitbox();

			if (!initialized)
				dance();

			if (isPlayer && initialized)
				flipX = !flipX;

			initialized = true;
		}
	}

	/**
	 * Gets the config JSON from `mods/yourMod/data/characters/yourChar/config.json` for this character and loads it.
	 * 
	 * **This function is designed to load Leather Engine JSONs, If you need to load a Psych or Yoshi JSON, use the `loadPsychJSON()` or `loadYoshiJSON()` functions.**
	 * @param mod The mod to load from.
	 */
	public function loadLeatherJSON(?mod:Null<String>) {
		var path:String = 'data/characters/$curCharacter/';

		if (FileSystem.exists(Paths.json('${path}config', mod))) {
			var config:LeatherCharacterConfig = cast tjson.TJSON.parse(Assets.load(TEXT, Paths.json('${path}config', mod)));

			if (!isPlayer)
				flipX = config.defaultFlipX;
			else
				flipX = !config.defaultFlipX;

			danceSteps = config.dancesLeftAndRight ? ["danceLeft", "danceRight"] : ["idle"];

			if (FileSystem.exists(Paths.txt('${path}${config.imagePath}')))
				frames = Assets.load(PACKER, Paths.image('../${path}${config.imagePath}', true, mod));
				// else if(FileSystem.exists(Paths.json("images/characters/" + config.imagePath + "/Animation.json", TEXT, "shared")))
			//	frames = AtlasFrameMaker.construct("characters/" + config.imagePath);
			else
				frames = Assets.load(SPARROW, Paths.image('../${path}${config.imagePath}', true, mod));

			var size:Null<Float> = config.graphicSize;

			if (size == null)
				size = config.graphicsSize;

			if (size != null)
				scale.set(size, size);

			for (selected_animation in config.animations) {
				if (selected_animation.indices != null && selected_animation.indices.length > 0) {
					animation.addByIndices(selected_animation.name, selected_animation.animation_name, selected_animation.indices, "", selected_animation.fps,
						selected_animation.looped);
				} else {
					animation.addByPrefix(selected_animation.name, selected_animation.animation_name, selected_animation.fps, selected_animation.looped);
				}
			}

			if (animation.exists("firstDeath"))
				playAnim("firstDeath");
			else if (!initialized)
				dance();

			if (debugMode)
				flipX = config.defaultFlipX;

			if (config.antialiased != null)
				antialiasing = config.antialiased;

			updateHitbox();

			if (config.positionOffset != null)
				positionOffset.set(config.positionOffset[0], config.positionOffset[1]);

			if (config.trail == true)
				trail = new FlxTrail(this, null, config.trailLength, config.trailDelay, config.trailStalpha, config.trailDiff);

			if (config.barColor == null)
				config.barColor = [255, 0, 0];

			healthBarColor = FlxColor.fromRGB(config.barColor[0], config.barColor[1], config.barColor[2]);

			if (config.cameraOffset != null) {
				if (flipX)
					config.cameraOffset[0] = 0 - config.cameraOffset[0];

				cameraOffset.add(config.cameraOffset[0], config.cameraOffset[1]);
			}

			if (config.deathCharacter != null)
				deathCharacter = config.deathCharacter;
			else if (config.deathCharacterName != null)
				deathCharacter = config.deathCharacterName;
			else
				deathCharacter = "bf-dead";

			if (config.healthIcon != null)
				healthIcon = config.healthIcon;
			else
				healthIcon = curCharacter;

			var offsets_string_array:Array<String> = CoolUtil.listFromText(Assets.load(TEXT, Paths.txt('${path}offsets')));

			for (offset_string in offsets_string_array) {
				var offset_data:Array<String> = offset_string.split(" ");
				setOffset(offset_data[0], Std.parseFloat(offset_data[1]), Std.parseFloat(offset_data[2]));
			}

			initialized = true;
		}
	}

	override public function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);
		specialAnim = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		script.call("onUpdate", [elapsed]);

		if (animTimer > 0) {
			animTimer -= elapsed;
			if (animTimer <= 0) {
				if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer') {
					specialAnim = false;
					dance();
				}
				animTimer = 0;
			}
		} else if (specialAnim && animation.curAnim.finished) {
			specialAnim = false;
			dance();
		}

		if (!isPlayer) {
			if (!debugMode) {
				if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed * (FlxG.state == PlayState.current ? FlxG.sound.music.pitch : 1.0);

				if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001) {
					dance();
					holdTimer = 0;
				}
			}
		} else {
			if (!debugMode) {
				if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed * (FlxG.state == PlayState.current ? FlxG.sound.music.pitch : 1.0);
				else
					holdTimer = 0;

				if (animation.curAnim != null && animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
					playAnim('idle', true, false, 10);
			}
		}

		if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
			playAnim(animation.curAnim.name + '-loop');

		if (canDance && animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		script.call("onUpdatePost", [elapsed]);
	}

	public var danced:Bool = false;

	/**
	 * Plays the correct idle animation for this character. (Only runs if `canDance` is set to `true`.)
	 */
	public function dance() {
		if (!canDance) return;
		if ((animation.curAnim != null && !animation.curAnim.name.startsWith("hair")) || animation.curAnim == null) {
			danced = !danced;

			if (danceSteps.length > 1) {
				if (curDanceStep > danceSteps.length - 1)
					curDanceStep = 0;

				playAnim(danceSteps[curDanceStep]);
				curDanceStep++;
			} else {
				playAnim(danceSteps[0]);
			}
		} else {
			playAnim(danceSteps[0]);
			curDanceStep = danceSteps.length > 1 ? 1 : 0;
		}

		script.call("onDance", []);
	}
}
