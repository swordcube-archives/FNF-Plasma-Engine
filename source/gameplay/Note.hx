package gameplay;

import gameplay.StrumNote;
import haxe.Json;
import shaders.ColorSwap;
import states.PlayState;
import sys.FileSystem;
import systems.Conductor;
import systems.ExtraKeys;
import systems.FNFSprite;

class Note extends FNFSprite
{
    public static var swagWidth:Float = 160*0.7;

    public var strumTime:Float = 0.0;

    public var parent:StrumLine;

    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    
    public var json:ArrowSkin;

    public var isSustain:Bool = false;
    public var mustPress:Bool = false;

    public var isDownScroll:Bool = Init.trueSettings.get("Downscroll");

    public var colorSwap:ColorSwap = new ColorSwap(255, 255, 255);

    public var noteYOff:Int = 0;
    
    public function new(x:Float, y:Float, noteData:Int = 0, isSustain:Bool = false)
    {
        super(x, y);

        this.noteData = noteData;
        this.isSustain = isSustain;

        shader = colorSwap;
        setColor();
    }

    public function setColor()
    {
        var colorArray = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
        colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
    }

    public function resetColor()
    {
        colorSwap.setColors(255, 255, 255);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var stepHeight = ((0.45 * Conductor.stepCrochet) * PlayState.current.scrollSpeed);

        if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
            scale.y = 0.7 * ((Conductor.stepCrochet / 100 * 1.5) * PlayState.current.scrollSpeed);

        if(isSustain)
        {
            flipY = isDownScroll;
            noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
            updateHitbox();
            offsetX();
        }
    }

    public function loadSkin(skin:String)
    {
        var path:String = AssetPaths.json('images/skins/$skin');
        if(FileSystem.exists(path))
        {
            json = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('images/skins/$skin')));

            frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
            var noteThing:String = ExtraKeys.arrowInfo[parent != null ? parent.keyCount-1 : keyCount-1][0][noteData];
            animation.addByPrefix("normal", noteThing+"0", 24, true);
            animation.addByPrefix("hold", noteThing+" hold0", 24, true);
            animation.addByPrefix("tail", noteThing+" tail0", 24, true);

            antialiasing = json.skin_type != "pixel" ? Init.trueSettings.get("Antialiasing") : false;

            scale.set(json.strum_scale, json.strum_scale);
            updateHitbox();

            playAnim("normal");
            if(isSustain)
            {
                alpha = Init.trueSettings.get("Opaque Sustains") ? 1 : 0.6;
                playAnim("hold");
            }
        }
        else
            Main.print("error", "Skin JSON file at "+path+" doesn't exist!");
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