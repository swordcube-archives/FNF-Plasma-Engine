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
    var use_color_shader:Bool;

    var is_quant:Bool;
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

        colorSwap = new ColorShader(255, 0, 0);

        shader = colorSwap;
        colorSwap.enabled.value = [false];
    }

    public function setColor()
    {
        var colorArray = Init.arrowColors[parent != null ? parent.keyCount-1 : keyCount-1][noteData];
        if(colorSwap != null && colorArray != null) // haxeflixel
            colorSwap.setColors(colorArray[0], colorArray[1], colorArray[2]);

        if(!json.use_color_shader && colorSwap != null)
            colorSwap.setColors(255, 0, 0);
    }

    public function resetColor() {
        colorSwap.setColors(255, 0, 0);
    }

    public function loadSkin(skinToLoad:String)
    {
        var skin:String = skinToLoad;
        if(Init.arrowSkins.exists(skin))
        {
            json = Init.arrowSkins[skin];

            var noteThing:String = ExtraKeys.arrowInfo[parent.keyCount-1][0][noteData];
            frames = FNFAssets.returnAsset(SPARROW, json.note_assets);
            animation.addByPrefix("static", noteThing+" static0", json.framerate, true);
            animation.addByPrefix("press", noteThing+" press0", json.framerate, false);
            animation.addByPrefix("confirm", noteThing+" confirm0", json.framerate, false);

            antialiasing = json.skin_type != "pixel" ? Settings.get("Antialiasing") : false;

            if(!json.use_color_shader)
                colorSwap.enabled.value = [false];

            var funnyScale:Float = json.strum_scale * ExtraKeys.arrowInfo[parent.keyCount-1][2];
            scale.set(funnyScale, funnyScale);
            updateHitbox();

            playAnim("static");
        }
        else
            Main.print("error", "Skin JSON file at "+path+" doesn't exist!");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(!json.use_color_shader)
            colorSwap.enabled.value = [false];
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (json.skin_type != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			var scale = json.strum_scale * ExtraKeys.arrowInfo[parent.keyCount-1][2];

			offset.x -= 156 * (scale / 2);
			offset.y -= 156 * (scale / 2);
		}
		else
			centerOffsets();

        if(!json.use_color_shader)
            colorSwap.enabled.value = [false];
    }
}