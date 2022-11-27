package funkin.game;

import base.AssetType;
import funkin.system.FNFSprite;

/**
 * A sprite that can dance left and right.
 */
class BackgroundDancer extends FNFSprite {
	var danceDir:Bool = false;

	public function dance():Void {
		danceDir = !danceDir;
		playAnim(danceDir ? 'danceRight' : 'danceLeft', true);
	}

	override public function load(type:AssetType, path:String):BackgroundDancer {
		return cast super.load(type, path);
	}
}
