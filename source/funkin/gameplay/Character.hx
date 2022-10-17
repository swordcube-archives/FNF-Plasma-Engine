package funkin.gameplay;

import flixel.addons.effects.FlxTrail;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import haxe.xml.Access;
import modding.HScript;
import modding.Script;
import scenes.PlayState;

using StringTools;
#if LUA_ALLOWED
import modding.LuaScript;
#end


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

class Character extends Sprite {
    public var mod:String = Paths.currentMod;
    public var curCharacter:String = "";
	public var deathCharacter:String = "bf-dead";

	public var healthIcon:String = "face";
    public var healthBarColor:FlxColor = FlxColor.BLACK;

    public var curDanceStep:Int = 0;
	public var danceSteps:Array<String> = ["idle"];
	public var canDance:Bool = true;

	public var isPlayer:Bool = false;

	public var singDuration:Float = 4;

	public var animTimer:Float = 0;
	public var holdTimer:Float = 0.0;

	public var specialAnim:Bool = false;
	public var debugMode:Bool = false;

    public var positionOffset:FlxPoint = new FlxPoint();
    public var cameraOffset:FlxPoint = new FlxPoint();
    public var ogPosition:FlxPoint = new FlxPoint();

    public var trail:FlxTrail;

    public var script:Script;

	public var stunned:Bool = false;

    public function new(x:Float, y:Float, isPlayer:Bool = false) {
        super(x, y);
        this.isPlayer = isPlayer;
        ogPosition = new FlxPoint(x, y);
    }

    public static function preloadCharacter(character:String, ?mod:Null<String>) {
        Assets.get(SPARROW, Paths.image('characters/$character/spritesheet', mod, true));
        var icon = new HealthIcon(character, false, mod);
    }

    public function loadCharacter(character:String, ?mod:Null<String>, ?returnSelf:Bool = true) {
        this.curCharacter = character;
        
        if(script != null) script.destroy();
        if(mod == null) mod = Paths.currentMod;
        this.mod = mod;

        script = Script.createScript('characters/$character/script');
        if(script.type == "unknown") { // Use the script's type (default is unknown) to check if it loaded
            script = Script.createScript('characters/template/script');
            this.curCharacter = "template";
        }
        switch(script.type) {
            case "hscript": 
				script.set("character", this);
				cast(script, HScript).setScriptObject(this);
            #if LUA_ALLOWED
            case "lua":
                // i hate working with lua everything has to be a function and it sucks omfg
                var script:LuaScript = cast this.script;
                script.set("curCharacter", curCharacter);
                script.setFunction("loadSparrow", function(path:String, ?mod:Null<String>, useRootFolder:Bool = true) {
                    frames = Assets.get(SPARROW, Paths.image(path, mod, useRootFolder));
                });
                script.setFunction("loadPacker", function(path:String, ?mod:Null<String>, useRootFolder:Bool = true) {
                    frames = Assets.get(PACKER, Paths.image(path, mod, useRootFolder));
                });
				script.setFunction("getProperty", function(object:String, variable:String) {
					var result:Dynamic = null;
					var split:Array<String> = variable.split('.');
					if(split.length > 1)
						result = LuaScript.getVarInArray(LuaScript.getPropertyLoopThingWhatever(split, true, this), split[split.length-1]);
					else
						result = LuaScript.getVarInArray(this, variable);
		
					if(result == null) llua.Lua.pushnil(script.lua);
					return result;
				});
				script.setFunction("setProperty", function(variable:String, value:Dynamic) {
					var split:Array<String> = variable.split('.');
					if(split.length > 1) {
						LuaScript.setVarInArray(LuaScript.getPropertyLoopThingWhatever(split, true, this), split[split.length-1], value);
						return true;
					}
					LuaScript.setVarInArray(this, variable, value);
					return true;
				});
                
                // animation functions grrr >:((
                script.setFunction("addAnim", function(type:String = "PREFIX", name:String, prefix:String, fps:Int, loop:Bool = false, ?offsets:Array<Float>, ?indices:Array<Int>) {
					if(offsets == null) offsets = [0, 0];
                    switch(type.toLowerCase()) {
                        case "prefix": addAnim(PREFIX, name, prefix, fps, loop, {x:offsets[0], y:offsets[1]}, indices);
                        case "indices": addAnim(INDICES, name, prefix, fps, loop, {x:offsets[0], y:offsets[1]}, indices);
                    }
                });
                script.setFunction("playAnim", function(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {playAnim(anim, force, reversed, frame);});
                script.setFunction("dance", function() {dance();});
                script.setFunction("setOffset", setOffset);

                // loading functions
                script.setFunction("loadPsychJSON", loadPsychJSON);
                script.setFunction("loadYoshiJSON", loadYoshiJSON);
                script.setFunction("loadLeatherJSON", loadLeatherJSON);
            #end
        }
        script.start();
		if(animation.curAnim == null)
			dance();

        this.x = ogPosition.x + positionOffset.x;
        this.y = ogPosition.y + positionOffset.y;
    }

    override public function setPosition(x:Float = 0, y:Float = 0) {
        super.setPosition(x, y);
        ogPosition = new FlxPoint(x, y);
        this.x += positionOffset.x;
        this.y += positionOffset.y;
    }

	public function loadPlasmaXML():Void {
		// Load the intial XML Data.
		var data:Access = new Access(Xml.parse(Assets.get(TEXT, Paths.xml('characters/$curCharacter/config'))).firstElement());

		// Load attributes from the 'character' node aka first element.
		frames = Assets.get(SPARROW, Paths.image('characters/$curCharacter/${data.att.spritesheet}', mod, false));
		antialiasing = data.att.antialiasing == 'true';
		singDuration = Std.parseFloat(data.att.sing_duration);
		healthIcon = data.att.icon;
		flipX = data.att.flip_x == "true";
		
		// Load animations
		var animations_node:Access = data.node.animations; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

		for (anim in animations_node.nodes.animation) {
			// Add the animation
			if (anim.has.indices && anim.att.indices.split(",").length > 1)
				animation.addByIndices(anim.att.name, anim.att.anim, CoolUtil.splitInt(anim.att.indices, ","), "", Std.parseInt(anim.att.fps), anim.att.looped == "true");
			else
				animation.addByPrefix(anim.att.name, anim.att.anim, Std.parseInt(anim.att.fps), anim.att.looped == "true");

			setOffset(anim.att.name, Std.parseFloat(anim.att.offsetX), Std.parseFloat(anim.att.offsetY));
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
		
		scrollFactor.set(Std.parseFloat(scroll.att.x), Std.parseFloat(scroll.att.y));

		if (icon_color.has.hex && icon_color.att.hex != "")
			healthBarColor = FlxColor.fromString(icon_color.att.hex);
		else
			healthBarColor = FlxColor.fromRGB(Std.parseInt(icon_color.att.r), Std.parseInt(icon_color.att.g), Std.parseInt(icon_color.att.b));

		// Dance Steps moment
		danceSteps = data.att.dance_steps.split(",");
		for(i in 0...danceSteps.length) danceSteps[i] = danceSteps[i].trim();
		dance();
	}

	public function loadPsychJSON() {
        frames = Assets.get(SPARROW, Paths.image('characters/$curCharacter/spritesheet', mod, false));
		var path:String = 'characters/$curCharacter/config';
		if (FileSystem.exists(Paths.json(path, mod))) {
			var json:PsychCharacter = tjson.TJSON.parse(Assets.get(TEXT, Paths.json(path, mod)));
			for (anim in json.animations) {
				if (anim.indices != null && anim.indices.length > 0)
					animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
				else
					animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

				setOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
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

			dance();
		}
	}

    public function loadYoshiJSON() {
        frames = Assets.get(SPARROW, Paths.image('characters/$curCharacter/spritesheet', mod, false));
		var path:String = 'characters/$curCharacter/config';
		if (FileSystem.exists(Paths.json(path))) {
            var json:YoshiCharacter = tjson.TJSON.parse(Assets.get(TEXT, Paths.json(path, mod)));
            cameraOffset.set(json.camOffset.x, json.camOffset.y);
            positionOffset.set(json.globalOffset.x, json.globalOffset.y);

            healthIcon = curCharacter;
            healthBarColor = FlxColor.fromString(json.healthbarColor);
            flipX = json.flipX;

            for(anim in json.anims) {
                if(anim.indices != null && anim.indices.length > 0)
                    animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
                else
                    animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

                setOffset(anim.name, anim.x, anim.y);
            }

            danceSteps = json.danceSteps;
            antialiasing = json.antialiasing ? Settings.get("Antialiasing") : false;

            scale.set(json.scale, json.scale);
            updateHitbox();

            dance();
        }
    }

	public function loadLeatherJSON() {
		var path:String = 'characters/$curCharacter/';

		if (FileSystem.exists(Paths.json('${path}config', mod))) {
			var config:LeatherCharacterConfig = cast tjson.TJSON.parse(Assets.get(TEXT, Paths.json('${path}config', mod)));

			if(!isPlayer)
				flipX = config.defaultFlipX;
			else
				flipX = !config.defaultFlipX;

            danceSteps = config.dancesLeftAndRight ? ["danceLeft", "danceRight"] : ["idle"];

			if(FileSystem.exists(Paths.txt('${path}${config.imagePath}')))
				frames = Assets.get(PACKER, Paths.image('../${path}${config.imagePath}', mod, true));
			//else if(FileSystem.exists(Paths.json("images/characters/" + config.imagePath + "/Animation.json", TEXT, "shared")))
			//	frames = AtlasFrameMaker.construct("characters/" + config.imagePath);
			else
				frames = Assets.get(SPARROW, Paths.image('../${path}${config.imagePath}.png', mod, true));

			var size:Null<Float> = config.graphicSize;

			if(size == null)
				size = config.graphicsSize;

			if(size != null)
				scale.set(size, size);

			for(selected_animation in config.animations) {
				if(selected_animation.indices != null && selected_animation.indices.length > 0) {
					animation.addByIndices(
						selected_animation.name,
						selected_animation.animation_name,
						selected_animation.indices, "",
						selected_animation.fps,
						selected_animation.looped
					);
				}
				else {
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
			else {
				if(config.dancesLeftAndRight)
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
	
				cameraOffset.add(config.cameraOffset[0], config.cameraOffset[1]);
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

			var offsets_string_array:Array<String> = CoolUtil.listFromText(Assets.get(TEXT, Paths.txt('${path}offsets', mod)));
			
			for (offset_string in offsets_string_array)
			{
				var offset_data:Array<String> = offset_string.split(" ");
				setOffset(offset_data[0], Std.parseFloat(offset_data[1]), Std.parseFloat(offset_data[2]));
			}
		}
	}

    override public function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);
		specialAnim = false;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		script.call("onUpdate", [elapsed]);
        script.call("update", [elapsed]);
        script.call("onProcess", [elapsed]);
        script.call("process", [elapsed]);

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
				holdTimer += elapsed * (FlxG.state == PlayState.current ? PlayState.songMultiplier : 1.0);

			if (holdTimer >= Conductor.stepCrochet * singDuration * 0.001) {
				dance();
				holdTimer = 0;
			}
		}

		if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.curAnim.name + '-loop'))
			playAnim(animation.curAnim.name + '-loop');

		if (canDance && animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');

		script.call("onUpdatePost", [elapsed]);
        script.call("updatePost", [elapsed]);
        script.call("processPost", [elapsed]);
        script.call("onProcessPost", [elapsed]);
	}

	public var danced:Bool = false;

	public function dance() {
		if (canDance) {
			if ((animation.curAnim != null && !animation.curAnim.name.startsWith("hair")) || animation.curAnim == null) {
				danced = !danced;
				
				if(danceSteps.length > 1) {
					if(curDanceStep > danceSteps.length-1)
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

			script.call("onDance");
		}
	}
}