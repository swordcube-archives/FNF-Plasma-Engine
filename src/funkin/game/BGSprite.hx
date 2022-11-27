package funkin.game;

import flixel.FlxSprite;

/**
 * A class for making sprites for a stage easier.
 */
class BGSprite extends FlxSprite {
	private var idleAnim:String;

	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false) {
		super(x, y);
		if (animArray != null) {
			frames = Assets.load(SPARROW, Paths.image(image));
			for (i in 0...animArray.length) {
				var anim:String = animArray[i];
				animation.addByPrefix(anim, anim, 24, loop);
				if (idleAnim == null) {
					idleAnim = anim;
					animation.play(anim);
				}
			}
		} else {
			if (image != null) {
				loadGraphic(Assets.load(IMAGE, Paths.image(image)));
			}
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = PlayerSettings.prefs.get("Antialiasing");
	}

	public function dance(?forceplay:Bool = false) {
		if (idleAnim != null)
			animation.play(idleAnim, forceplay);
	}
}