package states;

import flixel.FlxG;
import systems.MusicBeat;
import ui.FNFCheckbox;

/**
    A state that is for debugging.
**/
class CheckboxTest extends MusicBeatState
{
    var test:Bool = false;

    var checkbox:FNFCheckbox;

    override function create()
    {
        super.create();

        checkbox = new FNFCheckbox(0, 0, test);
        checkbox.screenCenter();
        add(checkbox);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SPACE)
        {
            test = !test;
            checkbox.status = test;
            checkbox.refresh();
        }
    }
}