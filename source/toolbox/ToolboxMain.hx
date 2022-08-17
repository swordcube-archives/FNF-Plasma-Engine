package toolbox;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import haxe.Json;
import substates.ModSelectionMenu.PackJSON;
import systems.MusicBeat;
import systems.UIControls;

class ToolboxMain extends MusicBeatState {
    var bg:FlxSprite;

    override function create() {
        super.create();

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

        var curModName:FlxText = new FlxText(curModIcon.x + (curModIcon.width + 10), curModIcon.y);
        curModName.text = json.name;
        curModName.setFormat(AssetPaths.font("vcr"), 32);
        add(curModName);

        FlxSpriteUtil.drawRoundRect(drr, 0, 0, drr.width, drr.height, 15, 15, FlxColor.BLACK);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
            Main.switchState(new states.ScriptedState('MainMenu'));
    }
}