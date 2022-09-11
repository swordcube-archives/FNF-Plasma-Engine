package gameplay;

import gameplay.StrumNote;
import haxe.Json;
import shaders.ColorShader;
import states.PlayState;
import sys.FileSystem;
import systems.Conductor;
import systems.ExtraKeys;
import systems.FNFSprite;

class Note extends FNFSprite {
    public static final quantColors:Array<Array<Int>> = [
        [249, 57, 63],    // red
        [83, 107, 239],   // blue
        [194, 75, 153],   // purple
        [0, 229, 80],     // green
        [96, 103, 137],   // gray
        [255, 122, 215],  // pink
        [255, 232, 61],   // yellow
        [174, 54, 230],   // purple but uglier
        [15, 235, 255],   // cyan
        [96, 103, 137],   // gray again
    ];

    public static var swagWidth:Float = 160*0.7;

    public var rawStrumTime:Float = 0.0;
    public var strumTime:Float = 0.0;

    public var parent:StrumLine;
    public var sustainParent:Note;

    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    public var rawNoteData:Int = 0;
    
    public var skin:String = "";
    public var json:ArrowSkin;

    public var isSustain:Bool = false;
    public var isEndPiece:Bool = false;
    
    public var mustPress:Bool = false;

    public var canBeHit:Bool = true;

    public var isDownScroll:Bool = Settings.get("Downscroll");

    public var colorSwap:ColorShader;

    public var noteYOff:Int = 0;

    public var altAnim:Bool = false;

    public var theColor:Array<Int> = [0, 0, 0];
    
    public function new(x:Float, y:Float, noteData:Int = 0, isSustain:Bool = false)
    {
        super(x, y);

        this.noteData = noteData;
        this.isSustain = isSustain;

        colorSwap = new ColorShader(255, 255, 255);

        shader = colorSwap;
    }

    public function setColor()
    {
        if(json.is_quant) {
            // forever engine code lol!!!!!!!!!
            // i have no fucking idea how quants work!!!
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193
            // https://github.com/Yoshubs/Forever-Engine-Legacy/blob/master/source/gameObjects/userInterface/notes/Note.hx#L193

			final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

			var curBPM:Float = Conductor.bpm;
			var newTime = rawStrumTime;
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (rawStrumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = rawStrumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
			final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
			// assumed 4 beats per measure?
			final measureTime:Float = beatTime * 4;

			final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

			for (quant in 0...quantArray.length)
			{
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
                    theColor = quantColors[quant];
					if(colorSwap != null)
                        colorSwap.setColors(quantColors[quant][0], quantColors[quant][1], quantColors[quant][2]);
					break;
				}
			}
        } else {
            var colorArray:Array<Int> = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
            theColor = colorArray;
            if(colorSwap != null && colorArray != null) // haxeflixel
                colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
        }
    }

    public function resetColor()
    {
        if(colorSwap != null) // haxeflixel
            colorSwap.setColors(255, 255, 255);
    }

    public var stepCrochet:Float = 0.0;
    var stepHeight:Float = 0.0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		stepHeight = ((0.45 * stepCrochet) * PlayState.current.scrollSpeed);

        if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
            scale.y = (json.sustain_scale * ExtraKeys.arrowInfo[parent != null ? parent.keyCount-1 : keyCount-1][2]) * ((stepCrochet / 100 * 1.5) * PlayState.current.scrollSpeed);

        if(isSustain)
        {
            flipY = isDownScroll;
            noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
            updateHitbox();
            offsetX();
        }

        if(!canBeHit)
            alpha = 0.35;
    }

    public function loadSkin(skin:String)
    {
        this.skin = skin;
        json = Init.arrowSkins[skin];

        var noteThing:String = ExtraKeys.arrowInfo[parent != null ? parent.keyCount-1 : keyCount-1][0][noteData];
        frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
        animation.addByPrefix("normal", noteThing+"0", 24, true);
        animation.addByPrefix("hold", noteThing+" hold0", 24, true);
        animation.addByPrefix("tail", noteThing+" tail0", 24, true);

        antialiasing = json.skin_type != "pixel" ? Settings.get("Antialiasing") : false;

        var funnyScale:Float = json.note_scale * ExtraKeys.arrowInfo[parent != null ? parent.keyCount-1 : keyCount-1][2];
        scale.set(funnyScale, funnyScale);
        updateHitbox();

        playAnim("normal");
        if(isSustain)
        {
            alpha = Settings.get("Opaque Sustains") ? 1 : 0.6;
            playAnim("hold");
        }

        setColor();
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (json.skin_type != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			var scale = json.strum_scale;

			offset.x -= 156 * (scale / 2);
			offset.y -= 156 * (scale / 2);
		}
		else
			centerOffsets();
    }

    function offsetX()
    {
		if (json.skin_type != "pixel")
        {
            offset.x = frameWidth / 2;

            var scale = json.note_scale;

            offset.x -= 156 * (scale / 2);
        }
        else
            offset.x = (frameWidth - width) * 0.5;
    }
}