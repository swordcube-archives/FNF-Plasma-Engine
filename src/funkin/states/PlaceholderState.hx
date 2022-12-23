package funkin.states;

import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;

/**
 * Yes, i am writing an entire fucking class for a placeholder.
 * 
 * Do not judge me.
 */
class PlaceholderState extends FNFState {
    var text:FlxText;

    var chosenColor:Int = 0;
    var rainbowList:Array<FlxColor> = [
        0xFFFF0000,
        0xFFFF7300,
        0xFFFFFB00,
        0xFF33FF00,
        0xFF00FFD5,
        0xFF006EFF,
        0xFF2F00FF,
        0xFFA200FF,
        0xFFFF00C8
    ];

    var textToDisplay:String = "Placeholder";

    public function new(?textToDisplay:String = "Placeholder") {
        super();
        this.textToDisplay = textToDisplay;
    }

    override function create() {
        super.create();
        text = new FlxText(0, 0, 0, textToDisplay, 32);
        text.setFormat(Paths.font("pixel.otf"), 32);
        text.screenCenter();
        add(text);
        dumbassTween();
    }

    function dumbassTween() {
        FlxTween.color(text, 2.5, text.color, rainbowList[chosenColor], {onComplete: function(twn:FlxTween) {
            dumbassTween(); // recursion!!!
        }});
        chosenColor = FlxMath.wrap(chosenColor+1, 0, rainbowList.length-1);
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

		if(controls.getP("BACK")) {
			CoolUtil.playMenuSFX(2);
			FlxG.switchState(new funkin.states.menus.MainMenuState());
		}
	}
}