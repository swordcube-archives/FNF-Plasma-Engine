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

    /**
        Creates a new notification with a title of `title`, description of `description`, and type of `type`.

        @param title             The title of this notification.
        @param description       The description of this notification.
        @param type              The type of this notification. (Can be `Error`, `Warn`, or `Info`.)
    **/
    public function new(title:String, description:String, type:NotificationType = Info)
    {
        super();

        box = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("notificationBox")));
        box.scale.set(6, 6);
        box.updateHitbox();
        box.x = FlxG.width - (box.width - 400);
        add(box);

        icon = new FlxSprite(box.x + 23, box.y + 23);
        icon.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("notificationIcons")), true, 16, 16);
        icon.animation.add("warn", [0], 24);
        icon.animation.add("error", [1], 24);
        icon.animation.add("info", [2], 24);
        switch(type)
        {
            case Error:
                icon.animation.play("error");
            case Warn | Warning:
                icon.animation.play("warn");
            case Info | Information:
                icon.animation.play("info");
        }
        icon.scale.set(6, 6);
        icon.updateHitbox();
        add(icon);

        this.title = new FlxText(icon.x + (icon.width + 20), icon.y, 0, title);
        this.title.setFormat(AssetPaths.font("pixel", OTF), 24);
        add(this.title);

        this.description = new FlxText(this.title.x, this.title.y + 30, 0, description);
        this.description.setFormat(AssetPaths.font("pixel", OTF), 17);
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