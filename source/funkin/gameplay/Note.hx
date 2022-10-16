package funkin.gameplay;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import misc.RGBFormat;
import scenes.PlayState;

typedef NoteSkin = {
    var image_location:String;
    var splash_image_location:String;
    
    var strum_scale:Float;
    var note_scale:Float;

    var sustain_scale:Float;
    var use_color_shader:Bool;

    var skin_type:String;

    var framerate:Int;
    var splash_framerate:Int;
};

class Note extends Sprite {
    public static var noteColors:Array<Array<Array<Int>>> = [];
    public static var noteDirections:Array<Array<String>> = [];
    public static var noteScales:Array<Float> = [];
    public static var noteSpacing:Array<Float> = [];

    public static var noteSkins:Map<String, NoteSkin> = [];
    
    public static var swagWidth:Float = 160 * 0.7;

    public var keyAmount:Int = 4;
    public var noteData:Int = 0;
    public var rawNoteData:Int = 0;

    public var stepCrochet:Float = 0;

    public var rawStrumTime:Float = 0;
    public var strumTime:Float = 0;
    public var isSustain:Bool = false;

    public var preventDeletion:Bool = false;

    public var altAnim:Bool = false;

    public var json:NoteSkin = null;
    public var noteYOff:Int = 0;

    public var sustainLength:Float = 0;

    public var parent:StrumLine;

    public var colorShader:ColorShader = new ColorShader(255, 0, 0);

    public function new(x:Float, y:Float, noteData:Int, isSustain:Bool = false) {
        super(x, y);
        this.noteData = noteData;
        this.isSustain = isSustain;
        shader = colorShader;
    }

    public function loadSkin(skin:String) {
        json = Note.noteSkins[skin];
        var direction:String = Note.noteDirections[keyAmount-1][noteData];
        
        frames = Assets.get(SPARROW, Paths.image(json.image_location));
        animation.addByPrefix("normal", direction+"0", json.framerate, false);
        animation.addByPrefix("hold", direction+" hold0", json.framerate, false);
        animation.addByPrefix("tail", direction+" tail0", json.framerate, false);

        scale.set(json.note_scale * Note.noteScales[keyAmount-1], json.note_scale * Note.noteScales[keyAmount-1]);
        updateHitbox();

        var color:RGBFormat = {
            r: Settings.noteColors[keyAmount-1][noteData][0],
            g: Settings.noteColors[keyAmount-1][noteData][1],
            b: Settings.noteColors[keyAmount-1][noteData][2]
        };
        colorShader.setColors(color.r, color.g, color.b);

        if(!json.use_color_shader)
            shader = null;
        else
            shader = colorShader;

        alpha = isSustain ? 0.6 : 1;
        playAnim(isSustain ? "hold" : "normal");

        antialiasing = json.skin_type != "pixel" ? Settings.get("Antialiasing") : false;
    }

    public var stepHeight:Float = 0.0;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(parent != null) {
            var speed:Float = (parent.noteSpeed/PlayState.songMultiplier);
            stepHeight = ((0.45 * stepCrochet) * speed);

            if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
                scale.y = json.sustain_scale * ((stepCrochet / 100 * 1.5) * speed);
    
            if(isSustain) {
                flipY = Settings.get("Downscroll");
                if(speed != Math.abs(speed))
                    flipY = !flipY;
                
                noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
                updateHitbox();
                offsetX();
            }

            x = parent.members[noteData].x;

            var downscrollShit:Bool = Settings.get("Downscroll");
            if(speed != Math.abs(speed))
                downscrollShit = !downscrollShit;

            var yOffset:Float = (downscrollShit ? noteYOff : -noteYOff);
            y = parent.members[noteData].y + ((Settings.get("Downscroll") ? 0.45 : -0.45) * (Conductor.position - strumTime) * speed) - yOffset;

            if(isSustain) {
                var stepHeight = (0.45 * stepCrochet * PlayState.SONG.speed);
                
                if(downscrollShit) {
                    y -= height - stepHeight;

                    if ((parent.isOpponent || (!parent.isOpponent && parent.pressed[noteData]))
                        && y - offset.y * scale.y + height >= (parent.y + Note.swagWidth / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, frameWidth * 2, frameHeight * 2);
                        swagRect.height = (parent.members[noteData].y + Note.swagWidth / 2 - y) / scale.y;
                        swagRect.y = frameHeight - swagRect.height;

                        clipRect = swagRect;
                    }
                } else {
                    y += 5;

                    if ((parent.isOpponent || (!parent.isOpponent && parent.pressed[noteData]))
                        && y + offset.y * scale.y <= (parent.y + Note.swagWidth / 2))
                    {
                        // Clip to strumline
                        var swagRect = new FlxRect(0, 0, width / scale.x, height / scale.y);
                        swagRect.y = (parent.members[noteData].y + Note.swagWidth / 2 - y) / scale.y;
                        swagRect.height -= swagRect.y;

                        clipRect = swagRect;
                    }
                }
            }
        }
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (json.skin_type != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			var scale = json.note_scale * Note.noteScales[keyAmount-1];

			offset.x -= 156 * (scale / 2);
			offset.y -= 156 * (scale / 2);
		}
		else
			centerOffsets();
    }

    public function offsetX()
    {
		centerOrigin();

		if (json.skin_type != "pixel")
		{
			offset.x = frameWidth / 2;

			var scale = json.note_scale * Note.noteScales[keyAmount-1];

			offset.x -= 156 * (scale / 2);
		}
		else
			offset.x = (frameWidth - width) * 0.5;
    }
}