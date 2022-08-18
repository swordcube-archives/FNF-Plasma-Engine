package toolbox;

import flixel.util.FlxColor;
import systems.UIControls;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import systems.MusicBeat;

class ToolboxEditor extends MusicBeatState
{
    var bg:FlxSprite;

    var closeBTN:FlxButton;

    override function create() {
        super.create();

        bg = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("menuBGGradient")));
        add(bg);

        closeBTN = new FlxButton(0, 0, "Exit", function() {
            Main.switchState(new toolbox.ToolboxMain());
        });
        closeBTN.color = FlxColor.RED;
        closeBTN.setPosition(FlxG.width - closeBTN.width, 0);
        add(closeBTN);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}