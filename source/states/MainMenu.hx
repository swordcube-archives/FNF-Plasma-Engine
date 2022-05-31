package states;

import base.Controls;
import base.MusicBeat.MusicBeatState;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class MainMenu extends MusicBeatState
{
    var menuBG:FlxSprite;
    var menuButtons:FlxTypedGroup<FlxSprite>;

    // add new shit here!
    // add images for new buttons in assets/images/mainMenu
    // make sure they are the same name as in the array.
    var menuOptions:Array<String> = [
        "story-mode",
        "freeplay",
        "mods",
        "replays",
        "credits",
        "options"
    ];
    
    override public function create()
    {
        super.create();
        
        menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBG', IMAGE));
        menuBG.scale.set(1.2, 1.2);
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.scrollFactor.set(0, 0.1);
        add(menuBG);

        menuButtons = new FlxTypedGroup<FlxSprite>();
        add(menuButtons);

        for(i in 0...menuOptions.length)
        {
            var button:FlxSprite = new FlxSprite();
            button.frames = GenesisAssets.getAsset('ui/mainMenu', SPARROW);
            button.screenCenter(X);
            button.scrollFactor.set(0, 0.1);
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(Controls.isPressed("BACK", JUST_PRESSED))
            States.switchState(this, new TitleState());
    }
}