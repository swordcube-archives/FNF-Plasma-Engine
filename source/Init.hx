package;

import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxState;
import haxe.ds.StringMap;

/**
	A class that initializes stuff, runs before the game starts.
    If you need something to get set before the game starts, Try going here first.
**/
class Init extends MusicBeatState
{
    // Key Name = Save Data Key
    // Value = The data used for the Options Menu
	public var options:StringMap<Option> = [
        "downscroll" => new Option(
            BOOL,
            "Downscroll",
		    "Choose whether to have the strumline vertically flipped in gameplay or not.",
            false
        ),
        "centered-notes" => new Option(
            BOOL,
            "Centered Notes",
		    "Centers all notes and hides your opponent's notes.",
            false
        ),
    ];

    override public function create()
    {
        FlxG.save.bind("genesis-options");

        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        GenesisAssets.init();
        States.switchState(this, new states.TitleState(), true);
    }
}
