package toolbox;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import systems.UIControls;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import systems.MusicBeat;

class ToolboxEditor extends MusicBeatState
{
    var bg:FlxSprite;

    var groups:Map<String, Array<FlxBasic>> = [
        "characters"  => [],
        "stages"      => [],
        "songs"       => [],
        "weeks"       => []
    ];

    var closeBTN:FlxButton;

    var objectGroup:FlxTypedGroup<FlxBasic>;

    override function create() {
        super.create();

        DiscordRPC.changePresence(
            "In the Toolbox",
            "Editing a mod"
        );

        Main.fpsCounter.visible = false;

        bg = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("menuBGGradient")));
        add(bg);

        objectGroup = new FlxTypedGroup<FlxBasic>();
        add(objectGroup);

        var btnPos:FlxPoint = new FlxPoint(0, 0); 
        var btnText:String = "Characters";
        var btn:FlxButton = new FlxButton(btnPos.x, btnPos.y, btnText, function() {
            trace("CHARACTERS PAGE");
        });
        add(btn);

        var btnPos:FlxPoint = new FlxPoint(btn.x + btn.width, 0); 
        var btnText:String = "Stages";
        var btn:FlxButton = new FlxButton(btnPos.x, btnPos.y, btnText, function() {
            trace("STAGES PAGE");
        });
        add(btn);

        var btnPos:FlxPoint = new FlxPoint(btn.x + btn.width, 0); 
        var btnText:String = "Songs";
        var btn:FlxButton = new FlxButton(btnPos.x, btnPos.y, btnText, function() {
            trace("SONGS PAGE");
        });
        add(btn);

        var btnPos:FlxPoint = new FlxPoint(btn.x + btn.width, 0); 
        var btnText:String = "Weeks";
        var btn:FlxButton = new FlxButton(btnPos.x, btnPos.y, btnText, function() {
            trace("WEEKS PAGE");
        });
        add(btn);

        closeBTN = new FlxButton(0, 0, "Exit", function() {
            Main.fpsCounter.visible = true;
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