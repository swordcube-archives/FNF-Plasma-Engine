package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.media.Sound;
import shaders.ColorShader;
import sys.FileSystem;
import systems.MusicBeat;
import systems.UIControls;
import ui.Alphabet;

using StringTools;

typedef PackJSON = {
    var name:String;
    var desc:String;
    var locked:Bool;
};

class ModSelectionMenu extends MusicBeatSubState {
    var scrollMenu:Sound = FNFAssets.returnAsset(SOUND, AssetPaths.sound("menus/scrollMenu"));
    var cancelMenu:Sound = FNFAssets.returnAsset(SOUND, AssetPaths.sound("menus/cancelMenu"));
    
    var grpAlphabet:FlxTypedGroup<Alphabet>;
    var grpIcons:FlxTypedGroup<ModSelectionIcon>;

    var curSelected:Int = 0;

    public function new()
    {
        super();

        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        grpAlphabet = new FlxTypedGroup<Alphabet>();
        add(grpAlphabet);

        grpIcons = new FlxTypedGroup<ModSelectionIcon>();
        add(grpIcons);

        var packFolders:Array<String> = FileSystem.readDirectory('${AssetPaths.cwd}assets');
        
        var i:Int = 0;
        for(folder in packFolders)
        {
            if(!folder.contains("."))
            {
                var json:PackJSON = Json.parse(FNFAssets.returnAsset(TEXT, AssetPaths.json("pack", folder)));

                var alphabet:Alphabet = new Alphabet(0, (70 * i) + 30, json.name, true);
                alphabet.x += 100;
                alphabet.xAdd += 150;
                alphabet.isMenuItem = true;
                alphabet.targetY = i;
                alphabet.scrollFactor.set();
                grpAlphabet.add(alphabet);

                var icon:ModSelectionIcon = new ModSelectionIcon(alphabet, folder);
                icon.scrollFactor.set();
                grpIcons.add(icon);

                i++;
            }
        }

        changeSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
        {
            FlxG.sound.play(cancelMenu);
            close();
        }

        if(UIControls.justPressed("UP"))
            changeSelection(-1);

        if(UIControls.justPressed("DOWN"))
            changeSelection(1);

        if(UIControls.justPressed("ACCEPT"))
        {
            AssetPaths.currentPack = grpIcons.members[curSelected].mod;

            FlxG.save.data.currentPack = AssetPaths.currentPack;
            FlxG.save.flush();

            Main.resetState();
            close();
        }
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = grpAlphabet.length - 1;

        if(curSelected > grpAlphabet.length - 1)
            curSelected = 0;

        var i:Int = 0;

        for(song in grpAlphabet.members)
        {
            song.targetY = i - curSelected;
            song.alpha = curSelected == i ? 1 : 0.6;

            i++;
        }

        FlxG.sound.play(scrollMenu);
    }
}

class ModSelectionIcon extends FlxSprite {
    public var mod:String = "";
    public var sprTracker:FlxSprite;

    public function new(sprTracker:FlxSprite, mod:String)
    {
        super();
        this.sprTracker = sprTracker;
        this.mod = mod;

        loadGraphic(FNFAssets.returnAsset(IMAGE, '${AssetPaths.cwd}assets/$mod/pack.png'));
        setGraphicSize(100, 100);
        updateHitbox();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(sprTracker != null)
            setPosition(sprTracker.x - 150, sprTracker.y);
    }
}