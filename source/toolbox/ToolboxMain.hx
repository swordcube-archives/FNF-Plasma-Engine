package toolbox;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import systems.MusicBeat;
import systems.UIControls;

class ToolboxMain extends MusicBeatState
{
    var bg:FlxSprite;
    var curMod:String;
    

    override function create() {
        super.create();
        if(curMod == null){
            curMod = "Test Mod lmao!";
        }
        DiscordRPC.changePresence(
            "In the Toolbox",
            "Selecting: " + curMod
        );

        FlxG.mouse.visible = true;
        
        // gonna atleast try to make an original ui for this menu
        // i might need some assistance
        bg = new FlxSprite();
        bg.loadGraphic(FNFAssets.returnAsset(IMAGE ,AssetPaths.image('menuBG')));
        bg.scale.set(1.2, 1.2);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set(0.17, 0.17);
        bg.antialiasing = Settings.get("Antialiasing");
        add(bg);
        FlxG.sound.playMusic(FNFAssets.returnAsset(SOUND, AssetPaths.music("freakyMenu")));
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