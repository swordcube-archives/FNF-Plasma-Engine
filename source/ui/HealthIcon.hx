package ui;

import flixel.FlxSprite;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;
	public var char:String = 'face';

	public var isPlayer:Bool = false;

	public var icons:Int = 0;

	public var copyAlpha:Bool = true;

	public function new(char:String = 'face', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			if (copyAlpha)
				alpha = sprTracker.alpha;

			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}

	public function changeIcon(char:String = 'face')
	{
		if (this.char != char)
		{
			this.char = char;

			icons = 0;

			var pixelIcons:Array<String> = CoolUtil.listFromText(FNFAssets.returnAsset(TEXT, AssetPaths.txt("pixelIcons")));

			// check if the icon exists, otherwise use default face
			var image = null;

			if(FileSystem.exists(AssetPaths.image('icons/$char')))
				image = FNFAssets.returnAsset(IMAGE, AssetPaths.image('icons/$char'));
			else
				image = FNFAssets.returnAsset(IMAGE, AssetPaths.image('icons/face'));

			loadGraphic(image);

			// detect how many icons there are automatically
			// becuase that's cool 8)
			var i:Int = 1;
			while (true)
			{
				if (width == height * i)
				{
					icons = i;
					// trace("detected " + icons + " icons");
					break;
				}
				i++;

				// basically a failsafe to prevent accidental freezes
				if (i > 100)
				{
					icons = 2;
					// trace("failed to detect icon count, icon count is now " + icons);
					break;
				}
			}

			loadGraphic(image, true, Math.floor(width / icons), Math.floor(height));
			updateHitbox();

			animation.add("normal", [0], 0, false, isPlayer);
			animation.add("losing", [1], 0, false, isPlayer);
			animation.add("winning", [2], 0, false, isPlayer);

			animation.play("normal");

			if(pixelIcons.contains(char))
				antialiasing = false;
			else
				antialiasing = Init.trueSettings.get('Antialiasing');
		}
	}
}