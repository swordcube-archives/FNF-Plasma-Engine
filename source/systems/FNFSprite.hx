package systems;

import flixel.FlxSprite;

class FNFSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Float>> = [];

	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		antialiasing = Init.trueSettings.get("Antialiasing");
	}

	public function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
	{
		if (animation.exists(anim))
		{
			animation.play(anim, force, reversed, frame);

			if (animOffsets.exists(anim))
				offset.set(animOffsets.get(anim)[0], animOffsets.get(anim)[1]);
			else
				offset.set(0, 0);
		}
	}

	public function setOffset(anim:String, x:Float = 0, y:Float = 0)
	{
		animOffsets.set(anim, [x, y]);
	}
}
