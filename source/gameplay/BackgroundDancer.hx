package gameplay;

import systems.FNFSprite;

class BackgroundDancer extends FNFSprite
{
	var danceDir:Bool = false;

	public function dance()
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}