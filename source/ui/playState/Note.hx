package ui.playState;

import base.Conductor;
import base.ManiaShit;
import flixel.FlxSprite;
import haxe.Json;
import states.PlayState;
import ui.playState.StrumNote;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

    public var inEditor:Bool = false;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
    public var sustainLength:Float = 0;
    public var isSustainNote:Bool = false;
    public var isEndOfSustain:Bool = false;
    public var earlyHitMult:Float = 0.5;
    public var prevNote:Note;
    
    public static var swagWidth:Float = 160 * 0.7;

    public var json:ArrowSkin = null;

    public function new(strumTime:Float, noteData:Int, skin:String, isSustainNote:Bool = false, isEndOfSustain:Bool = false)
    {
        this.noteData = noteData;
        this.strumTime = strumTime;
        this.isSustainNote = isSustainNote;
        this.isEndOfSustain = isEndOfSustain;
        
        super();
        
        loadSkin(skin);
    }

    public function loadSkin(skin:String = 'arrows')
    {
        json = Json.parse(GenesisAssets.getAsset('images/ui/skins/$skin/config.json', TEXT));
        
        switch(json.skinType)
        {
            case "standard":
                frames = GenesisAssets.getAsset('ui/skins/$skin/notes', SPARROW);
                
                antialiasing = true;

                var keyCount:Int = PlayState.songData.keyCount;

                animation.addByPrefix("normal", ManiaShit.letterDirections[keyCount][noteData] + "0", 24, true);
                animation.addByPrefix("hold", ManiaShit.letterDirections[keyCount][noteData] + " hold", 24, false);
                animation.addByPrefix("tail", ManiaShit.letterDirections[keyCount][noteData] + " tail", 24, false);
        }

        scale.set(json.arrowScale, json.arrowScale);
        
        updateHitbox();

        if(isSustainNote)
        {
            if(isEndOfSustain)
                playAnim("tail");
            else
                playAnim("hold");
        }
        else
            playAnim("normal");
    }

	public function playAnim(anim:String, ?force:Bool = false)
    {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
                if(prevNote != null)
                {
				    if((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					    wasGoodHit = true;
                }
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}