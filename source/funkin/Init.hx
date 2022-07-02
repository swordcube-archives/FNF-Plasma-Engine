package funkin;

import flixel.FlxG;
import funkin.game.FunkinState;

/**
    A class for doing things before the game switches to TitleState.
    
    The reason this class extends FunkinState is because i don't want TitleState to have a transition when the game starts >:(
**/
class Init extends FunkinState
{
    public var initState = new funkin.menus.TitleState(); 

    override public function create()
    {
        super.create();
        
        Preferences.init();

		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start

        switchState(initState, true);
    }
}