package gameplay;

import systems.FNFSprite;

class BGSprite extends FNFSprite
{
	public var idleAnim:String = null;

	public function new(image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1, scrollY:Float = 1, animations:Array<String> = null, loopAnims:Bool = false)
	{
		super(x, y);
		
		if (animations != null)
		{
			frames = FNFAssets.returnAsset(SPARROW, image);
			for (anim in animations)
			{
				animation.addByPrefix(anim, anim, 24, loopAnims);
				animation.play(anim);
				if (idleAnim == null)
					idleAnim = anim;
			}
		}
		else
		{
			loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image(image)));
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = Settings.get("Antialiasing");
	}

	public function dance()
	{
		if (idleAnim != null)
			animation.play(idleAnim);
	}
}