package gameplay;

import haxe.Json;
import shaders.ColorShader;
import sys.FileSystem;
import systems.ExtraKeys;
import systems.FNFSprite;

typedef ArrowSkin = {
    var skin_type:String;
    
    var note_assets:String;
    var splash_assets:String;

    var framerate:Int;

    var strum_scale:Float;
    var note_scale:Float;

    var sustain_scale:Float;
};

class StrumNote extends FNFSprite {
    public var parent:StrumLine;

    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    
    public var json:ArrowSkin;

    public var colorSwap:ColorShader;
    
    public function new(x:Float, y:Float, noteData:Int = 0)
    {
        super(x, y);

        this.noteData = noteData;

        colorSwap = new ColorShader(255, 255, 255);

        shader = colorSwap;
        colorSwap.enabled.value = [false];
    }

    public function setColor()
    {
        var colorArray = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
        if(colorSwap != null && colorArray != null) // haxeflixel
            colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);
    }

    public function resetColor()
    {
        colorSwap.setColors(255, 255, 255);
    }

    public function loadSkin(skinToLoad:String)
    {
        var skin:String = skinToLoad;
        
        var path:String = AssetPaths.json('images/skins/$skin');
        if(!FileSystem.exists(path))
        {
            skin = "arrows";
            path = AssetPaths.json('images/skins/$skin');
        }

        if(FileSystem.exists(path))
        {
            json = Init.arrowSkins[skin];

            var noteThing:String = ExtraKeys.arrowInfo[parent.keyCount-1][0][noteData];
            if(json.skin_type == "pixel")
            {
                loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image(json.note_assets)), true, 17, 17);
                animation.add("static", [noteData], json.framerate, true);
                animation.add("press", [noteData+4, noteData+8], json.framerate, false);
                animation.add("confirm", [noteData+12, noteData+16], json.framerate, false);
            }
            else
            {
                frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
                animation.addByPrefix("static", noteThing+" static0", json.framerate, true);
                animation.addByPrefix("press", noteThing+" press0", json.framerate, false);
                animation.addByPrefix("confirm", noteThing+" confirm0", json.framerate, false);
            }

            antialiasing = json.skin_type != "pixel" ? Settings.get("Antialiasing") : false;

            var funnyScale:Float = json.strum_scale * ExtraKeys.arrowInfo[parent.keyCount-1][2];
            scale.set(funnyScale, funnyScale);
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