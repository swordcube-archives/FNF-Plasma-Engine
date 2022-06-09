package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class NotificationToast extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var strip:FlxSprite;
    public var icon:FlxSprite;

    public var titleTxt:FlxText;
    public var descriptionTxt:FlxText;

    public static var presetColors:Map<String, FlxColor> = [
        "ERROR" => FlxColor.fromString("#ff4f4f"),
        "WARNING" => FlxColor.fromString("#ffc74d"),
        "INFO" => FlxColor.fromString("#5279ff")
    ];

    public var title:String = "";
    public var description:String = "";
    public var stripColor:FlxColor = FlxColor.WHITE;    

    public function new(title:String, description:String, stripColor:FlxColor, toastStatus:ToastStatus, ?customIcon:Dynamic)
    {
        super();
        
        this.title = title;
        this.description = description;
        this.stripColor = stripColor;
        
        bg = new FlxSprite().makeGraphic(400, 80, FlxColor.BLACK);
        bg.x = FlxG.width - bg.width;
        add(bg);

        strip = new FlxSprite(0, bg.y).makeGraphic(10, Std.int(bg.height), stripColor);
        strip.x = bg.x - strip.width;
        add(strip);

        icon = new FlxSprite().loadGraphic(GenesisAssets.getAsset('ui/toasts/$toastStatus', IMAGE));
        icon.setGraphicSize(60, 60);
        icon.updateHitbox();
        icon.setPosition(bg.x + 10, bg.y + 10);
        add(icon);

        titleTxt = new FlxText(icon.x + (icon.width + 10), icon.y - 5, bg.width - (icon.width + 10), title, 24);
        titleTxt.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 24, FlxColor.WHITE, LEFT);
        add(titleTxt);

        descriptionTxt = new FlxText(titleTxt.x, titleTxt.y + 30, bg.width - (icon.width + 10), description, 16);
        descriptionTxt.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 16, FlxColor.WHITE, LEFT);
        add(descriptionTxt);

        this.x = FlxG.width - 10;

        FlxTween.tween(this, {x: 0}, 1.5, {
            ease: FlxEase.cubeOut
        });

        new FlxTimer().start(4, function(tmr:FlxTimer) {
            FlxTween.tween(this, {x: FlxG.width}, 1.5, {
                ease: FlxEase.cubeIn
            });
        });
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(x >= FlxG.width)
        {
            kill();
            destroy();
        }
    }
}

@:enum abstract ToastStatus(String) to String
{
	var ERROR = 'error';
	var WARNING = 'warning';
	var INFO = 'info';
}