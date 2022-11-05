package funkin.states.substates;

import flixel.FlxSubState;

class FunkinSubState extends FlxSubState {
    override function update(elapsed:Float) {
		if(FlxG.keys.justPressed.F5)
			Main.resetState();

        super.update(elapsed);
    }
}