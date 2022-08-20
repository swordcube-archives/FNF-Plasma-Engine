package toolbox;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import systems.MusicBeat;
import systems.UIControls;

class ToolboxEditor extends MusicBeatState
{
    var bg:FlxSprite;

    override function create() {
        super.create();

        DiscordRPC.changePresence(
            "In the Toolbox",
            "Editing a mod"
        );

        // gonna atleast try to make an original ui for this menu
        // i might need some assistance

        var trolled:FlxText = new FlxText(0, 0, 0, "get trolled");
        trolled.setFormat(AssetPaths.font("vcr"), 24);
        trolled.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        add(trolled);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
            Main.switchState(new toolbox.ToolboxMain());
    }
}