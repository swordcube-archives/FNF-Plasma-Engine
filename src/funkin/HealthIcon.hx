package funkin;

import funkin.states.PlayState;
import flixel.math.FlxMath;
import flixel.graphics.FlxGraphic;

class HealthIcon extends Sprite {
    public var sprTracker:flixel.FlxSprite;
    public var copyAlpha:Bool = true;

    public var char:String = "face";

    public var healthIconSteps:Array<Array<Dynamic>> = [];
    
    /**
        Ranges from 0-100.
    **/
    public var iconHealth(get, default):Float = 50;
    function get_iconHealth():Float {
		var boundedAss = FlxMath.bound(iconHealth, 0, 100);
        iconHealth = boundedAss;
        return boundedAss;
	}

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

        healthIconSteps = [];
        var bitch:Array<Int> = [for(i in 0...frames.numFrames) i];
        var g:Int = bitch.length;
        for(i in bitch) {
            healthIconSteps.push([(100.0 / bitch.length) / i+1, g]);
            g--;
        };
        if(healthIconSteps.length > 1) {
            healthIconSteps[0][1] = 1;
            healthIconSteps[1][1] = 0;
        }
        animation.add('icon', bitch, 0, false);
		animation.play('icon');

        if(FlxG.state == PlayState.current) {
            trace("GUH:"+iconHealth);
            for(shit in healthIconSteps) {
                trace(shit[0]);
            }
        }
        
        return this;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(FlxG.state == PlayState.current) {
            for(shit in healthIconSteps) {
                if(iconHealth >= shit[0])
                    animation.curAnim.curFrame = shit[1];
            }
        }

        if (sprTracker != null) {
            setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
            if(copyAlpha) alpha = sprTracker.alpha;
        }
    }
}