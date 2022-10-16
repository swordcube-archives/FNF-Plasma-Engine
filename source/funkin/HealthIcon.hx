package funkin;

import flixel.FlxSprite;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite;
	public var curCharacter:String = null;
	public var mod:Null<String> = null;
	public var isPlayer:Bool = false;
	public var icons:Int = 0;
	public var copyAlpha:Bool = true;

	public function new(char:String = 'face', isPlayer:Bool = false, ?mod:Null<String>) {
		super();
		this.isPlayer = isPlayer;
		this.mod = mod;
		changeIcon(char);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) {
			if (copyAlpha)
				alpha = sprTracker.alpha;

			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}

	public function changeIcon(char:String = 'face') {
		if (this.curCharacter != char) {
			this.curCharacter = char;

			icons = 0;

			var pixelIcons:Array<String> = [];

			var basePath:String = '${Sys.getCwd()}assets/';
			for(folder in FileSystem.readDirectory(basePath)) {
				if(FileSystem.exists(basePath+folder) && FileSystem.isDirectory(basePath+folder)) {
					var list = CoolUtil.listFromText(Assets.get(TEXT, Paths.txt("pixelIcons", folder)));
					for(item in list) {
						if(!pixelIcons.contains(item))
							pixelIcons.push(item);
					}
				}
			}

			// check if the icon exists, otherwise use default face
			var image = Assets.get(IMAGE, Paths.image('characters/template/icons', null, false));

			if(FileSystem.exists(Paths.image('characters/$char/icons', null, false)))
				image = Assets.get(IMAGE, Paths.image('characters/$char/icons', null, false));

			if(FileSystem.exists(Paths.image('icons/$char')))
				image = Assets.get(IMAGE, Paths.image('icons/$char'));

			loadGraphic(image);

			// detect how many icons there are automatically
			// becuase that's cool 8)
			var i:Int = 1;
			while (true) {
				if (width == height * i) {
					icons = i;
					break;
				}
				i++;

				// basically a failsafe to prevent accidental freezes
				if (i > 100) {
					icons = 2;
					break;
				}
			}

			loadGraphic(image, true, Math.floor(width / icons), Math.floor(height));
			updateHitbox();

			animation.add("normal", [0], 0, false, isPlayer);
			animation.add("losing", [1], 0, false, isPlayer);
			animation.add("winning", [2], 0, false, isPlayer);

			animation.play("normal");

			antialiasing = pixelIcons.contains(char) ? false : Settings.get('Antialiasing');
		}
	}
}