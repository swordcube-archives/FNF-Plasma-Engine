package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum NotificationType {
    Error;
    Warn;
    Warning;
    Info;
    Information;
}

class Notification extends FlxSpriteGroup
{
    public var box:FlxSprite;
    public var icon:FlxSprite;

    public var title:FlxText;
    public var description:FlxText;

    public var shouldDie:Bool = false;

    public function new(title:String, description:String, type:NotificationType = Info)
    {
        super();

        box = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("notificationBox")));
        box.scale.set(0.9, 0.9);
        box.updateHitbox();
        box.x = FlxG.width - (box.width - 10);
        box.antialiasing = Settings.get("Antialiasing");
        add(box);

        icon = new FlxSprite(box.x + 25, box.y + 25);
        icon.frames = FNFAssets.returnAsset(SPARROW, 'notificationIcons');
        icon.animation.addByPrefix("error", "error0", 24);
        icon.animation.addByPrefix("warn", "warn0", 24);
        icon.animation.addByPrefix("info", "info0", 24);
        switch(type)
        {
            case Error:
                icon.animation.play("error");
            case Warn | Warning:
                icon.animation.play("warn");
            case Info | Information:
                icon.animation.play("info");
        }
        icon.antialiasing = Settings.get("Antialiasing");
        icon.scale.set(0.9, 0.9);
        icon.updateHitbox();
        add(icon);

        this.title = new FlxText(icon.x + (icon.width + 20), icon.y, 0, title);
        this.title.setFormat(AssetPaths.font("gotham", OTF), 24);
        add(this.title);

        this.description = new FlxText(this.title.x, this.title.y + 30, 0, description);
        this.description.setFormat(AssetPaths.font("gotham", OTF), 17);
        add(this.description);

        x = box.width;

        FlxTween.tween(this, { x: 0 }, 1, { ease: FlxEase.cubeOut });
        die(6);
    }

    public function die(delay:Float = 4)
        FlxTween.tween(this, { x: box.width }, 1, { ease: FlxEase.cubeIn, startDelay: delay, onComplete: function(twn:FlxTween) {
            shouldDie = true;
        }});
}