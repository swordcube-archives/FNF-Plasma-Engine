package states;

import base.Conductor;
import flixel.FlxG;
import flixel.FlxState;
import ui.Alphabet;

class TitleState extends FlxState
{
	var alphabet:Alphabet;
	
	override public function create()
	{
		super.create();

		GenesisAssets.init();

		Conductor.changeBPM(102);

		alphabet = new Alphabet(50, 50, "no title yet sorry lmao", true);
		alphabet.screenCenter();
		add(alphabet);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.play(GenesisAssets.getAsset('confirmMenu', SOUND)); // test to see if sounds work
		}
	}
}
