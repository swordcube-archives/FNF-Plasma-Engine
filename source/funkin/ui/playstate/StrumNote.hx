package funkin.ui.playstate;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.FunkinSprite;
import funkin.game.Note;
import funkin.game.PlayState;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import haxe.Json;

typedef ArrowSkin =
{
	var ratingSkin:String; // this is here if you wanna reuse rating assets from another skin. not recommended for modded skins
	var comboSkin:String; // same thing as ratingSkin but for the combo numbers
	var noteSplashesSkin:String; // same thing as ratingSkin and comboSkin but for the note splashes
	var countdownSkin:String; // same thing as ratingSkin and comboSkin and noteSplashesSkin but for the ready, set, and go graphics
    var healthBarSkin:String; // same thing as the last 4 things above but for the health bar, use an .hx file for custom layering
	var arrowScale:Float; // change how big the notes are, 0.7 = default, 6 = pixel
	var ratingScale:Float; // change how big the ratings are, 0.7 = default, 6 = pixel
	var comboScale:Float; // change how big the combo numbers are, 0.7 = default, 6 = pixel
	var skinType:String; // specify how the arrows are loaded - "standard" = sparrows, "pixel" = png spritesheet
	var arrowSize:Array<Dynamic>; // specify the size for each arrow (only used in "pixel" skinType)
	var arrowFrames:Array<Dynamic>; // specify what frames each animation uses (only used in "pixel" skinType)
};

class StrumNote extends FunkinSprite
{
    public var animFinished:Bool = false;
    
    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    public var json:ArrowSkin;

    public function new(x:Float, y:Float, keyCount:Int, noteData:Int, skin:String)
    {
        super(x, y);

        this.keyCount = keyCount;
        this.noteData = noteData;

        changeSkin(skin);
    }

    public function changeSkin(skin:String)
    {
        json = Json.parse(FunkinAssets.getText(Paths.json('images/ui/skins/$skin/config')));
        
        frames = FunkinAssets.getSparrow('ui/skins/$skin/strums');
        addAnimByPrefix("static", Note.arrowDirections[keyCount][noteData] + " static0", 24, true);
        addAnimByPrefix("press", Note.arrowDirections[keyCount][noteData] + " press0", 24, false);
        addAnimByPrefix("confirm", Note.arrowDirections[keyCount][noteData] + " confirm0", 24, false);

        scale.set(json.arrowScale, json.arrowScale);
        updateHitbox();

        antialiasing = json.skinType != "pixel";
        
        playAnim("static");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(animation.curAnim != null && animation.curAnim.finished)
            animFinished = true;
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
    {
        super.playAnim(name, force, reversed, frame);

		centerOrigin();

		if (json.skinType != "pixel")
		{
			offset.x = frameWidth / 2;
			offset.y = frameHeight / 2;

			var scale = json.arrowScale;

			offset.x -= 156 * (scale / 2);
			offset.y -= 156 * (scale / 2);
		}
		else
			centerOffsets();

		animFinished = false;
    }
}