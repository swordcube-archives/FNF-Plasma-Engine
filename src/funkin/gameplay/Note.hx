package funkin.gameplay;

import funkin.states.PlayState;
import scripting.Script;
import scripting.ScriptModule;
import shaders.ColorShader;

typedef NoteInfo = {
    var directions:Array<String>;
    var colors:Array<Array<Int>>;
    var scale:Float;
    var spacing:Float;
}

class Note extends Sprite {
    public static final spacing:Float = 160 * 0.7;
    public static final keyInfo:Map<Int, NoteInfo> = [
        1  => {
            directions: ["space"],
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
            directions: ["left", "space", "right"],
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
    ];

    public var strumTime:Float = 0.0;
    public var rawStrumTime:Float = 0.0;
    public var direction:Int = 0;
    public var parent:StrumLine;

    public var isSustain:Bool = false;
    public var isSustainTail:Bool = false;

    public var altAnim:Bool = false;

    public var noteScale:Float = 0.7;
    public var skin(default, set):String;

    public var stepCrochet:Float = 0.0;
    public var noteYOff:Int = 0;

    public var type:String = "Default Note";
    public var useRGBShader:Bool = false;

    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    public var script:ScriptModule;

    function set_skin(v:String):String {
        skin = v;
        reloadSkin();
		return skin = v;
	}

    public function reloadSkin() {
        switch(skin) {
            case "Arrows":
                frames = Assets.load(SPARROW, Paths.image("ui/notes/NOTE_assets"));
                var dir:String = Note.keyInfo[parent.keyCount].directions[direction];
                addAnim("normal", dir+"0");
                addAnim("hold", dir+" hold0");
                addAnim("tail", dir+" tail0");
                sustainScale = 0.7;
                noteScale = 0.7 * Note.keyInfo[parent.keyCount].scale;
                scale.set(noteScale, noteScale);
                updateHitbox();
                playAnim(isSustain ? "hold" : "normal");
                if(isSustainTail) playAnim("tail");
        }
    }

    public function new(x:Float = 0, y:Float = 0, parent:StrumLine, direction:Int = 0, isSustain:Bool = false, isSustainTail:Bool = false, skin:String = "Arrows", type:String = "Default Note") {
        super(x, y);
        this.direction = direction;
        this.isSustain = isSustain;
        this.isSustainTail = isSustainTail;
        this.parent = parent;
        this.skin = skin;
        this.type = type;
        // Initialize this note's script
        script = Script.create(Paths.hxs('data/scripts/note_types/$type'));
        script.start(true, []);
    }

    public var stepHeight:Float = 0.0;
    public var sustainScale:Float = 0.7;
    override function update(elapsed:Float) {
        super.update(elapsed);
        var speed:Float = (parent.noteSpeed/PlayState.current.songSpeed);
        stepHeight = ((0.45 * stepCrochet) * speed);

        if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
            scale.y = sustainScale * ((stepCrochet / 100 * 1.5) * speed);

        if(isSustain) {
            flipY = Settings.get("Downscroll");
            noteYOff = Math.round(-stepHeight + spacing * 0.5);
            updateHitbox();
            offsetX();
        }
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (skin != "pixel") {
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			offset.x -= 156 * (noteScale / 2);
			offset.y -= 156 * (noteScale / 2);
		} else
			centerOffsets();
    }

    public function offsetX() {
        if (skin != "pixel") {
			offset.x = frameWidth / 2;
			offset.x -= 156 * (noteScale / 2);
		} else
            offset.x = (frameWidth - width) * 0.5;
    }

    override public function destroy() {
        script.destroy();
        super.destroy();
    }
}