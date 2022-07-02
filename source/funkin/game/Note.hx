package funkin.game;

import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.ui.playstate.StrumNote.ArrowSkin;
import haxe.Json;

class Note extends FunkinSprite
{
    public var keyCount:Int = 4;
    public var noteData:Int = 0;
    public var json:ArrowSkin;
    
    public static var swagWidth:Float = 160.0 * 0.7;
    public static var arrowDirections:Map<Int, Array<String>> = [
        1 => ["E"],
        2 => ["A", "D"],
        3 => ["A", "E", "D"],
        4 => ["A", "B", "C", "D"],
        5 => ["A", "B", "E", "C", "D"],
        6 => ["A", "B", "D", "F", "H", "I"],
        7 => ["A", "B", "D", "E", "F", "H", "I"],
        8 => ["A", "B", "C", "D", "F", "G", "H", "I"],
        9 => ["A", "B", "C", "D", "E", "F", "G", "H", "I"],
    ];

    public static var singAnims:Map<Int, Array<String>> = [
        1 => ["singUP"],
        2 => ["singLEFT", "singRIGHT"],
        3 => ["singLEFT", "singUP", "singRIGHT"],
        4 => ["singLEFT", "singDOWN", "singUP", "singRIGHT"],
        5 => ["singLEFT", "singDOWN", "singUP", "singUP", "singRIGHT"],
        6 => ["singLEFT", "singDOWN", "singRIGHT", "singLEFT", "singUP", "singRIGHT"],
        7 => ["singLEFT", "singDOWN", "singRIGHT", "singUP", "singLEFT", "singUP", "singRIGHT"],
        8 => ["singLEFT", "singDOWN", "singUP", "singRIGHT", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
        9 => ["singLEFT", "singDOWN", "singUP", "singRIGHT", "singUP", "singLEFT", "singDOWN", "singUP", "singRIGHT"],
    ];

    public var mustPress:Bool = false;
    public var downScroll:Bool = false;

    public var isSustain:Bool = false;

    public var prevNote:Note;

    public var strumTime:Float;

    public var noteYOff:Int = 0;

    public function new(x:Float, y:Float, isSustain:Bool, keyCount:Int, noteData:Int, skin:String)
    {
        super(x, y);

        this.isSustain = isSustain;
        this.keyCount = keyCount;
        this.noteData = noteData;

        changeSkin(skin);
    }

    public function changeSkin(skin:String)
    {
        json = Json.parse(FunkinAssets.getText(Paths.json("images/ui/skins/default/config")));
        
        frames = FunkinAssets.getSparrow("ui/skins/default/notes");
        addAnimByPrefix("normal", Note.arrowDirections[keyCount][noteData] + "0", 24, true);
        addAnimByPrefix("hold", Note.arrowDirections[keyCount][noteData] + " hold0", 24, true);
        addAnimByPrefix("tail", Note.arrowDirections[keyCount][noteData] + " tail0", 24, true);

        scale.set(json.arrowScale, json.arrowScale);
        updateHitbox();

        playAnim("normal");
    }

    public var animFinished:Bool = false;

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		var stepHeight = ((0.45 * Conductor.stepCrochet) * PlayState.scrollSpeed);

        if(isSustain)
        {
            if(!Preferences.opaqueSustains)
                alpha = 0.6;
            
            noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
            updateHitbox();
            offsetX();
        }

        if(isSustain && animation.curAnim != null && animation.curAnim.name != "tail")
            scale.y = 0.7 * ((Conductor.stepCrochet / 100 * 1.5) * PlayState.scrollSpeed);

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

    function offsetX()
    {
		if (json.skinType != "pixel")
        {
            offset.x = frameWidth / 2;

            var scale = json.arrowScale;

            offset.x -= 156 * (scale / 2);
        }
        else
            offset.x = (frameWidth - width) * 0.5;
    }
}