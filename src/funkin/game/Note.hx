package funkin.game;

import funkin.scripting.Script;
import funkin.shaders.ColorShader;
import funkin.system.FNFSprite;
import funkin.states.PlayState;
import flixel.FlxSprite;

using StringTools;

@:dox(hide)
typedef NoteInfo = {
    var directions:Array<String>;
    var colors:Array<Array<Int>>;
    var scale:Float;
    var spacing:Float;
}

@:dox(hide)
typedef NoteSkin = {
	var strumTextures:String;
	var noteTextures:String;

	var strumScale:Float;
	var noteScale:Float;
	var sustainScale:Float;

	var isPixel:Bool;
	var noteColorsAllowed:Bool;
	var quantCompatible:Bool;
	var pixelNoteSize:Array<Int>;

	var staticFrameRate:Int;
	var pressedFrameRate:Int;
	var confirmFrameRate:Int;
	var noteFrameRate:Int;

	var splashSkin:String;
}

@:dox(hide)
typedef NoteSplashSkin = {
	var texturePath:String;
	var scale:Float;

	var frameRate:Int;
	var offsets:Array<Int>;
	var offsets2:Array<Int>;
	var noteColorsAllowed:Bool;
	var alpha:Float;
};

@:dox(hide)
typedef NoteTypeScript = {
	var code:String;
	var ext:String;
}

class Note extends FNFSprite {
	public static final keyInfo:Map<Int, NoteInfo> = [
        1  => {
            directions: ["middle"],
            colors: [[0, -100, 0]],
            scale: 1,
            spacing: 1
        },
        2  => {
            directions: ["left", "right"],
            colors: [[194, 75, 153], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
        3  => {
            directions: ["left", "middle", "right"],
            colors: [[194, 75, 153], [204, 204, 204], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
        4  => {
            directions: ["left", "down", "up", "right"],
            colors: [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
		5  => {
            directions: ["left", "down", "middle", "up", "right"],
            colors: [[194, 75, 153], [0, 255, 255], [204, 204, 204], [18, 250, 5], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
		6  => {
            directions: ["left", "down", "right", "left", "up", "right"],
            colors: [[194, 75, 153], [18, 250, 5], [249, 57, 63], [255, 253, 16], [0, 255, 255], [5, 44, 246]],
            scale: 0.8,
            spacing: 0.85
        },
    ];

	public static var splashSkinJSONs:Map<String, NoteSplashSkin> = [];
	public static var skinJSONs:Map<String, NoteSkin> = [];
	public static var noteTypeScripts:Map<String, NoteTypeScript> = [];

	public var rawStrumTime:Float = 0;
	public var strumTime:Float = 0;

	public var shouldHit:Bool = true;
	public var mustPress:Bool = false;
	public var keyAmount:Int = 4;

    public var directionName:String = "left";

	public var rawDirection:Int = 0;
    public var direction(default, set):Int = 0;

    function set_direction(v:Int):Int {
		if(v < 0)
			directionName = "left";
		else
        	directionName = Note.keyInfo[keyAmount].directions[v];
		return direction = v;
	}
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var isColorable(default, set):Bool = true;

	public var sustainPieces:Array<Note> = [];

	function set_isColorable(v:Bool) {
		if(v && skinJSON.noteColorsAllowed) {
			shader = colorShader;
			return isColorable = v;
		}
		shader = null;
		return isColorable = false;
	}

	public var canSplash:Bool = true;

	public var prevNote:Note;
	public var parent:StrumLine;
	
	public var splashSkin:String = "Default";
	public var type(default, set):String = "Default";

	public var script:ScriptModule;
	public var colorShader:ColorShader = new ColorShader(255, 0, 0);
	public var noteScale:Float = 0.7;

	public var doSingAnim:Bool = true;

	public var ogHeight:Float = 0;

	function set_type(v:String) {
		switch(v) {
			default:
				reloadSkin();

				if(noteTypeScripts[v] != null)
					script = Script.load(noteTypeScripts[v].ext, noteTypeScripts[v].code);
				else 
					script = new ScriptModule("");
				
				script.set("this", this);
				script.run();

				var rgb = direction < 0 ? [255, 0, 0] : keyInfo[keyAmount].colors[direction];
				colorShader.setColors(rgb[0], rgb[1], rgb[2]);
				shader = (isColorable && skinJSON.noteColorsAllowed) ? colorShader : null;
		}
		return type = v;
	}

	public function reloadSkin() {
		if(type != "Default") return;

		skinJSON = skinJSONs[FlxG.state == PlayState.current ? PlayState.current.noteSkin.replace("Default", PlayerSettings.prefs.get("Note Skin")) : PlayerSettings.prefs.get("Note Skin")];
		// Crash prevention?!?! Psych take notes
		if(skinJSON == null) skinJSON = skinJSONs["Default"];

		noteScale = skinJSON.noteScale;
		this.load(SPARROW, Paths.image(skinJSON.noteTextures));
		animation.addByPrefix("normal", directionName+"0", skinJSON.noteFrameRate);
		animation.addByPrefix("hold", directionName+" hold0", skinJSON.noteFrameRate);
		animation.addByPrefix("tail", directionName+" tail0", skinJSON.noteFrameRate);
		ogHeight = height;
		scale.set(skinJSON.noteScale, skinJSON.noteScale);
		updateHitbox();
		playCorrectAnim();

		antialiasing = skinJSON.isPixel ? false : PlayerSettings.prefs.get("Antialiasing");
		splashSkin = skinJSON.splashSkin;
	}

	public var stepCrochet:Float = 0;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainTail:Bool = false;

	public var altAnim:Bool = false;

	public static var spacing:Float = 160 * 0.7;

	@:dox(hide) public var skinJSON:NoteSkin;

	public function new(strumTime:Float, keyAmount:Int, direction:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?type:String = "Default") {
		super();

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.strumTime = strumTime;
		this.keyAmount = keyAmount;
		this.direction = direction;
		this.type = type;
	}

	public function playCorrectAnim() {
		playAnim(isSustainTail ? "tail" : (isSustainNote ? "hold" : "normal"));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(parent != null) {
			var speed:Float = (parent.noteSpeed/FlxG.sound.music.pitch);

            if(isSustainNote && !isSustainTail)
                scale.y = skinJSON.sustainScale * ((stepCrochet / 100 * 1.5) * speed);
    
            if(isSustainNote) {
                flipY = PlayerSettings.prefs.get("Downscroll");
                if(speed != Math.abs(speed))
                    flipY = !flipY;
                
                updateHitbox();
                offsetX();
            }
		}

		if (mustPress) {
			var hitMults:Array<Float> = shouldHit ? [1.5, 1.5] : [0.5, 0.5];
			if (strumTime > Conductor.position - Conductor.safeZoneOffset * hitMults[0]
				&& strumTime < Conductor.position + Conductor.safeZoneOffset * hitMults[1])
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.position - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		} else {
			canBeHit = false;
		}

		if (tooLate) alpha = 0.3;
	}

	override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        super.playAnim(name, force, reversed, frame);

        centerOrigin();
        if (!skinJSON.isPixel) {
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			offset.x -= 156 * (noteScale / 2);
			offset.y -= 156 * (noteScale / 2);
		} else centerOffsets();
    }

	public function offsetX() {
		if (!skinJSON.isPixel) {
			offset.x = frameWidth / 2;
			offset.x -= 156 * (noteScale / 2);
		} else offset.x = (frameWidth - width) * 0.5;
	}

	override public function destroy() {
		if(PlayState.current != null) PlayState.current.scripts.removeScript(script);
		script.destroy();
		super.destroy();
	}
}
