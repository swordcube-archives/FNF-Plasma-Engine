package toolbox;


import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import systems.MusicBeat;
import systems.UIControls;

class ToolboxWarning extends MusicBeatState
{
    var clickText:FlxText;
    // sword if your looking at this dont yeet all the code this is for displaying a warning before entering the toolbox because e - vizz
    // also for no reason i cant switch to this in the main menu because it isnt a varible guh??
    override function create() {
        super.create();
        DiscordRPC.changePresence(
            "In the Toolbox",
            "not sure what to put here lmao"
        );

        FlxG.mouse.visible = true;
        

        clickText = new FlxText(0, 0, 0, "Just so you know this is still being worked on\nPress enter to continue");
        clickText.setFormat(AssetPaths.font("vcr"), 24);
        clickText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        clickText.screenCenter();
        add(clickText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
        {
            FlxG.mouse.visible = false;
            Main.switchState(new states.ScriptedState('MainMenu'));
        }
        if(UIControls.justPressed("ENTER")) 
            {
                // sussy balls
                remove(clickText);
                Main.switchState(new ToolboxMain());
        }
    }
}