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
    public static var swagWidth:Float = 160*0.7;

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
    
    public function new(x:Float, y:Float, noteData:Int = 0, isSustain:Bool = false)
    {
        super(x, y);

        this.noteData = noteData;
        this.isSustain = isSustain;

        colorSwap = new ColorShader(255, 255, 255);

        shader = colorSwap;
        setColor();
    }

    public function setColor()
    {
        var colorArray:Array<Int> = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
        if(colorSwap != null && colorArray != null) // haxeflixel
            colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
    }

    public function resetColor()
    {
        if(colorSwap != null) // haxeflixel
            colorSwap.setColors(255, 255, 255);
    }

    var stepHeight:Float = 0.0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		stepHeight = ((0.45 * Conductor.stepCrochet) * PlayState.current.scrollSpeed);

        if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
            scale.y = (json.sustain_scale / ExtraKeys.arrowInfo[parent != null ? parent.keyCount-1 : keyCount-1][2]) * ((Conductor.stepCrochet / 100 * 1.5) * PlayState.current.scrollSpeed);

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
        if(json.skin_type == "pixel")
        {
            loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image(json.note_assets)), true, 17, 17);
            animation.add("normal", [noteData+4], 24, true);
            animation.add("hold", [noteData+20], 24, true);
            animation.add("tail", [noteData+24], 24, true);
        }
        else
        {
            frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
            animation.addByPrefix("normal", noteThing+"0", 24, true);
            animation.addByPrefix("hold", noteThing+" hold0", 24, true);
            animation.addByPrefix("tail", noteThing+" tail0", 24, true);
        }

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