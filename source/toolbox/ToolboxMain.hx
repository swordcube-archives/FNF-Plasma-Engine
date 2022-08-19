package toolbox;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Json;
import substates.ModSelectionMenu.PackJSON;
import systems.MusicBeat;
import systems.UIControls;

class ToolboxMain extends MusicBeatState
{
    var bg:FlxSprite;

    var selectBTN:FlxButton;
    var editBTN:FlxButton;

    override function create() {
        super.create();

        DiscordRPC.changePresence(
            "In the Toolbox",
            "Selecting a mod"
        );

        FlxG.mouse.visible = true;

        bg = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("menuBGGradient")));
        add(bg);

        // Dumbass Rounded Rect
        var drr:FlxSprite = new FlxSprite().makeGraphic(700, 300, FlxColor.TRANSPARENT);
        drr.screenCenter();
        drr.alpha = 0.6;
        add(drr);

        var curModIcon:FlxSprite = new FlxSprite(drr.x + 20, drr.y + 20);
        curModIcon.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.asset("pack.png")));
        curModIcon.setGraphicSize(100, 100);
        curModIcon.updateHitbox();
        add(curModIcon);

        var json:PackJSON = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json("pack")));

        var curModName:FlxText = new FlxText(curModIcon.x + (curModIcon.width + 10), curModIcon.y, drr.width - (curModIcon.width + 20));
        curModName.text = json.name;
        curModName.setFormat(AssetPaths.font("vcr"), 32);
        add(curModName);

        var curModDesc:FlxText = new FlxText(curModName.x, curModName.y + 40, drr.width - (curModIcon.width + 20));
        curModDesc.text = json.desc;
        curModDesc.setFormat(AssetPaths.font("vcr"), 24);
        add(curModDesc);

        selectBTN = new FlxButton(0, 0, "Select Mod", function() {
            openSubState(new substates.ModSelectionMenu());
        });
        selectBTN.setPosition(drr.x + (drr.width - (selectBTN.width + 10)), drr.y + (drr.height - (selectBTN.height + 10)));
        add(selectBTN);

        if(!json.locked)
        {
            editBTN = new FlxButton(0, 0, "Edit Mod", function() {
                Main.switchState(new toolbox.ToolboxEditor());
            });
            editBTN.setPosition(selectBTN.x - (selectBTN.width + 10), selectBTN.y);
            add(editBTN);
        }

        FlxSpriteUtil.drawRoundRect(drr, 0, 0, drr.width, drr.height, 15, 15, FlxColor.BLACK);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
        {
            FlxG.mouse.visible = false;
            Main.switchState(new states.ScriptedState('MainMenu'));
        }
    }
}