package gameplay;

import haxe.Json;
import shaders.ColorSwap;
import sys.FileSystem;
import systems.ExtraKeys;
import systems.FNFSprite;

typedef ArrowSkin = {
    var skin_type:String;
    
    var note_assets:String;

    var strum_scale:Float;
    var note_scale:Float;
};

class StrumNote extends FNFSprite
{
    public var parent:StrumLine;

    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    
    public var json:ArrowSkin;

    public var colorSwap:ColorSwap = new ColorSwap(255, 255, 255);
    
    public function new(x:Float, y:Float, noteData:Int = 0)
    {
        super(x, y);

        this.noteData = noteData;

        shader = colorSwap;
        colorSwap.enabled.value = [false];
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

    public function loadSkin(skin:String)
    {
        var path:String = AssetPaths.json('images/skins/$skin');
        if(FileSystem.exists(path))
        {
            json = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json('images/skins/$skin')));

            frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
            var noteThing:String = ExtraKeys.arrowInfo[parent.keyCount-1][0][noteData];
            animation.addByPrefix("static", noteThing+" static0", 24, true);
            animation.addByPrefix("press", noteThing+" press0", 24, false);
            animation.addByPrefix("confirm", noteThing+" confirm0", 24, false);

            antialiasing = json.skin_type != "pixel" ? Init.trueSettings.get("Antialiasing") : false;

            scale.set(json.strum_scale, json.strum_scale);
            updateHitbox();

            playAnim("static");
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