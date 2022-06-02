package ui.playState;

import base.ManiaShit;
import flixel.FlxSprite;
import haxe.Json;

typedef ArrowSkin = {
    var ratingSkin:String; // this is here if you wanna reuse rating assets from another skin. not recommended for modded skins
    var comboSkin:String; // same thing as ratingSkin but for the combo numbers
    var noteSplashesSkin:String; // same thing as ratingSkin and comboSkin but for the note splashes
    var countdownSkin:String; // same thing as ratingSkin and comboSkin and noteSplashesSkin but for the ready, set, and go graphics
    var arrowScale:Float; // change how big the notes are, 0.7 = default, 6 = pixel
    var ratingScale:Float; // change how big the ratings are, 0.7 = default, 6 = pixel
    var comboScale:Float; // change how big the combo numbers are, 0.7 = default, 6 = pixel
    var skinType:String; // specify how the arrows are loaded - "standard" = sparrows, "pixel" = png spritesheet
    var arrowSize:Array<Dynamic>; // specify the size for each arrow (only used in "pixel" skinType)
    var arrowFrames:Array<Dynamic>; // specify what frames each animation uses (only used in "pixel" skinType)
};

class StrumNote extends FlxSprite
{
    public var json:ArrowSkin = null;
    
    var noteData:Int = 0;
    var keyCount:Int = 4;
    
    public function new(x:Float, y:Float, skin:String, noteData:Int, keyCount:Int)
    {
        this.noteData = noteData;
        this.keyCount = keyCount;
        
        super(x, y);
        
        loadSkin(skin);
    }

    public function loadSkin(skin:String = 'arrows')
    {
        json = Json.parse(GenesisAssets.getAsset('images/ui/skins/$skin/config.json', TEXT));

        switch(json.skinType)
        {
            case "standard":
                frames = GenesisAssets.getAsset('ui/skins/$skin/strums', SPARROW);
                antialiasing = true;
                animation.addByPrefix("static", ManiaShit.letterDirections[keyCount][noteData] + " static", 24, true);
                animation.addByPrefix("press", ManiaShit.letterDirections[keyCount][noteData] + " press", 24, false);
                animation.addByPrefix("confirm", ManiaShit.letterDirections[keyCount][noteData] + " confirm", 24, false);
        }

        scale.set(json.arrowScale, json.arrowScale);

        updateHitbox();

        playAnim("static");
    }

	public function playAnim(anim:String, ?force:Bool = false)
    {
		animation.play(anim, force);

		centerOrigin();

        if(json.skinType != "pixel")
        {
            offset.x = frameWidth / 2;
            offset.y = frameHeight / 2;

            var scale = json.arrowScale;

            offset.x -= 156 * (scale / 2);
            offset.y -= 156 * (scale / 2);
        }
        else
            centerOffsets();
    }
}