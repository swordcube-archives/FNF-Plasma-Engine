package funkin.gameplay;

import flixel.math.FlxMath;
import funkin.states.PlayState;
import flixel.ui.FlxBar;
import flixel.group.FlxGroup;

/**
 * A custom class for a health bar.
 * Customize this to your liking.
 */
class HealthBar extends FlxGroup {
	public var bg:Sprite;
	public var bar:FlxBar;

    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

	public function new(x:Float = 0, y:Float = 0) {
		super();
		bg = new Sprite(x, y).load(IMAGE, Paths.image("ui/healthBar"));
		bg.screenCenter(X);
		add(bg);

		bar = new FlxBar(bg.x + 6, bg.y + 5, RIGHT_TO_LEFT, Std.int(bg.width - 12), Std.int(bg.height - 9), PlayState.current, "health", PlayState.current.minHealth, PlayState.current.maxHealth);
        bar.createFilledBar(0xFFFF0000, 0xFF66FF33);
        add(bar);

        iconP2 = new HealthIcon(0, bar.y - 72).loadIcon("dad");
        add(iconP2);

        iconP1 = new HealthIcon(0, bar.y - 72).loadIcon("bf");
        iconP1.flipX = true;
        add(iconP1);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        iconP2.iconHealth = 100 - bar.percent;
        iconP1.iconHealth = bar.percent;

        var iconOffset:Int = 26;
		iconP1.x = bar.x + (bar.width * (FlxMath.remapToRange(bar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = bar.x + (bar.width * (FlxMath.remapToRange(bar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

        iconP2.scale.x = MathUtil.fixedLerp(iconP2.scale.x, 1, 0.15);
        iconP2.scale.y = MathUtil.fixedLerp(iconP2.scale.y, 1, 0.15);
        iconP2.updateHitbox();

        iconP1.scale.x = MathUtil.fixedLerp(iconP1.scale.x, 1, 0.15);
        iconP1.scale.y = MathUtil.fixedLerp(iconP1.scale.y, 1, 0.15);
        iconP1.updateHitbox();
    }

    public function beatHit(curBeat:Int) {
        iconP2.scale.set(1.2, 1.2);
        iconP2.updateHitbox();

        iconP1.scale.set(1.2, 1.2);
        iconP1.updateHitbox();
    }
}
