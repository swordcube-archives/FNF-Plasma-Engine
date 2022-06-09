package ui.playState;

import funkin.FNFSprite;
import states.PlayState;

class NoteSplash extends FNFSprite
{
	public function new(x:Float, y:Float, direction:String = "A")
	{
		super(x, y);

		frames = GenesisAssets.getAsset('ui/skins/${PlayState.instance.uiSkin}/noteSplashes', SPARROW);
		animation.addByPrefix(direction, direction, 24, false);

		scale.set(0.65, 0.65);
		updateHitbox();

		alpha = 0.6;

		addOffset(direction, (width / 1.75) + 4, (height / 1.75) - 5);

		playAnim(direction);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (animation.curAnim.finished)
			kill();
	}
}
