package gameplay;

import gameplay.StrumNote;
import haxe.Json;
import shaders.ColorSwap;
import sys.FileSystem;
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

    public var colorSwap:ColorSwap = new ColorSwap();
    
    public function new(x:Float, y:Float, noteData:Int = 0, isSustain:Bool = false)
    {
        super(x, y);

        this.noteData = noteData;

        shader = colorSwap.shader;
        setColor();
    }

    public function setColor()
    {
        colorSwap.hue = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData][0]/360;
        colorSwap.saturation = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData][1]/100;
        colorSwap.brightness = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData][2]/100;
    }

    public function resetColor()
    {
        colorSwap.hue = 0;
        colorSwap.saturation = 0;
        colorSwap.brightness = 0;
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
                playAnim("hold");
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
}