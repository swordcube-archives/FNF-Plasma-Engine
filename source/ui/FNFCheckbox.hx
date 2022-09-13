package ui;

import flixel.FlxSprite;
import systems.FNFSprite;

class FNFCheckbox extends FNFSprite {
    public var sprTracker:FlxSprite;
    public var status:Bool = false;

    public function new(x:Float = 0, y:Float = 0, status:Bool)
    {
        super(x, y);
        this.status = status;

        frames = FNFAssets.returnAsset(SPARROW, "checkbox");
        animation.addByPrefix("off", "off", 24, true);
        animation.addByPrefix("on", "on", 24, false);

        scale.set(0.2, 0.2);

        antialiasing = Settings.get("Antialiasing");

        setOffset("off", 0, 0);
        setOffset("on", 7, 7);

        refresh();
    }

    public function refresh()
        playAnim(status ? "on" : "off");
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(sprTracker != null)
        {
            alpha = sprTracker.alpha;
            x = sprTracker.x - 270;
            y = sprTracker.y - 170;
        }
    }
}