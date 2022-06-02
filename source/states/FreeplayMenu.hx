package states;

import base.Controls;
import base.CoolUtil;
import base.MusicBeat.MusicBeatState;
import base.SongLoader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import ui.Alphabet;
import ui.HealthIcon;

class FreeplayMenu extends MusicBeatState
{
    var menuBG:FlxSprite;
    var songList:FlxTypedGroup<Alphabet>;
    var iconList:FlxTypedGroup<HealthIcon>;

    var scrollMenu:Dynamic;
    var cancelMenu:Dynamic;

    static var curSelected:Int = 0;

    var songs:Array<FreeplaySong> = [];
    
    override public function create()
    {
        super.create();
        scrollMenu = GenesisAssets.getAsset('menus/scrollMenu', SOUND);
        cancelMenu = GenesisAssets.getAsset('menus/cancelMenu', SOUND);

        menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBGDesat', IMAGE));
        add(menuBG);

        songList = new FlxTypedGroup<Alphabet>();
        add(songList);

        iconList = new FlxTypedGroup<HealthIcon>();
        add(iconList);

        var assetsJson:SongListJson = Json.parse(Assets.getText('assets/data/freeplaySongs.json'));
        for(i in 0...assetsJson.songs.length)
        {
            var song = assetsJson.songs[i];
            addSong(i, song.name, song.icon, song.color);
            songs.push(assetsJson.songs[i]);
        }

        changeSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        menuBG.color = FlxColor.interpolate(menuBG.color, FlxColor.fromString(songs[curSelected].color), CoolUtil.camLerpShit(0.045));

        if(Controls.isPressed("BACK", JUST_PRESSED))
        {
            FlxG.sound.play(cancelMenu);
            States.switchState(this, new MainMenu());
        }

        if(Controls.isPressed("UI_UP", JUST_PRESSED))
            changeSelection(-1);

        if(Controls.isPressed("UI_DOWN", JUST_PRESSED))
            changeSelection(1);

        if(Controls.isPressed("ACCEPT", JUST_PRESSED))
        {
            PlayState.SONG = SongLoader.loadJSON(songs[curSelected].name.toLowerCase(), "normal");
            States.switchState(this, new PlayState());
        }
    }

    function addSong(index:Int = 0, name:String, ?icon:Null<String> = "face", ?color:Null<String> = "#000000")
    {
        var songText:Alphabet = new Alphabet(0, (70 * index) + 30, name, true, false);
        songText.isMenuItem = true;
        songText.targetY = index;
        songText.ID = index;
        songList.add(songText);

        var icon:HealthIcon = new HealthIcon(icon);
        icon.sprTracker = songText;
        iconList.add(icon);
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;
        if(curSelected < 0)
            curSelected = songList.length - 1;
        if(curSelected > songList.length - 1)
            curSelected = 0;

        FlxG.sound.play(scrollMenu);

        songList.forEach(function(text:Alphabet) {
            text.targetY = text.ID - curSelected;
            if(curSelected == text.ID)
                text.alpha = 1;
            else
                text.alpha = 0.6;
        });
    }
}

typedef FreeplaySong =
{
    var name:String;
    var icon:String;
    var color:String;
    var difficulties:Array<String>;
}

typedef SongListJson =
{
    var songs:Array<FreeplaySong>;
}