package funkin;

import flixel.graphics.FlxGraphic;

class HealthIcon extends Sprite {
    public var sprTracker:flixel.FlxSprite;
    public var copyAlpha:Bool = true;

    public var char:String = "face";

    public function new(x:Float = 0, y:Float = 0, char:String = "face") {
        super(x, y);
        loadIcon(char);
    }

    public function loadIcon(char:String) {
        this.char = char;
        if(!FileSystem.exists(Paths.image('icons/$char'))) {
            char = "face";
            this.char = char;
        }
        var iconGraphic:FlxGraphic = Assets.load(IMAGE, Paths.image('icons/$char'));
		loadGraphic(iconGraphic, true, iconGraphic.height, iconGraphic.height);

        animation.add('icon', [for(i in 0...frames.numFrames) i], 0, false);
		animation.play('icon');
        
        return this;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (sprTracker != null) {
            setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
            if(copyAlpha) alpha = sprTracker.alpha;
        }
    }
}