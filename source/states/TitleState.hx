package states;

import flixel.FlxG;
import flixel.FlxState;

class TitleState extends FlxState
{
	override public function create()
	{
		super.create();

		GenesisAssets.init();
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
