package funkin.ui;

import funkin.system.TrackingSprite;
import funkin.states.PlayState;
import flixel.math.FlxMath;
import flixel.graphics.FlxGraphic;

/**
 * An extension of a `TrackingSprite` for health bar icons.
 */
class HealthIcon extends TrackingSprite {

    /**
     * The character used for this icon.
     */
    public var char:String = "face";
    
    /**
     * The amount of icons detected.
     */
    public var iconAmount:Int = 0;
    
    /**
        Ranges from 0-100.
    **/
    public var iconHealth(get, default):Float = 50;
    function get_iconHealth():Float {
		var boundedAss = FlxMath.bound(iconHealth, 0, 100);
        iconHealth = boundedAss;
        return boundedAss;
	}

    /**
    * Loads an icon from "images/icons".
    * @param char The character's icon to load
    * @param updateOffset Whether or not the offset should be adjusted for icon heights bigger or smaller than 150.
    * @author swordcube
    */
    public function loadIcon(char:String, ?updateOffset:Bool = false) {
        this.char = char;
        if(!FileSystem.exists(Paths.image('icons/$char'))) {
            char = "face";
            this.char = char;
        }
        var iconGraphic:FlxGraphic = Assets.load(IMAGE, Paths.image('icons/$char'));
		loadGraphic(iconGraphic, true, iconGraphic.height, iconGraphic.height);

        iconAmount = frames.numFrames;
        var bitch = [for(i in 0...frames.numFrames) i];
        var oldBitch = [for(i in 0...frames.numFrames) i];
        if(bitch.length > 1) {
            bitch[0] = oldBitch[1];
            bitch[1] = oldBitch[0];
        }
        animation.add('icon', bitch, 0, false);
		animation.play('icon');
        if(updateOffset)
            updateHitbox();
        if(bitch.length > 1) animation.curAnim.curFrame = 1;
        
        return this;
    }

    /**
    * Gets desired icon index from specified data.
    * @param health Amount of health from 0 to 100 to use.
    * @param icons Amount of icons in our checks.
    * @return Int
    * @author Leather128
    */
    // modified this a bit because this was funky as hell with 2 icons
    // made it so if there's 1 icon it always returns 0 because well
    // there's no other frames
    function getIconIndex(health:Float, icons:Int):Int {
        switch(icons) {
            case 1:
                return 0;
            case 2:
                if(health < 20) return 0;
                return 1;
            case 3:
                if(health < 20) return 0;
                if(health > 80) return 2;
                return 1;
            default:
                for (i in 0...icons) {
                    if (health > (100.0 / icons) * (i+1)) continue;
                    
                    // finds the first icon we are less or equal to, then choose it
                    return i;
                }
        }
        return 0;
    }

    override function updateHitbox() {
        super.updateHitbox();

        offset.y = frameHeight * 0.5;
        offset.y += ((1-scale.y)*frameHeight)*0.5;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(FlxG.state == PlayState.current) animation.curAnim.curFrame = getIconIndex(iconHealth, iconAmount);
    }
}