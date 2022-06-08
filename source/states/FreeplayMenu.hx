package states;

import base.Controls;
import base.CoolUtil;
import base.Highscore;
import base.MusicBeat.MusicBeatState;
import base.SongLoader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
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
    static var curDifficulty:Int = 1;

    var songs:Array<FreeplaySong> = [];

    // Score
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;
    
    override public function create()
    {
        super.create();

        if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
            FlxG.sound.playMusic(GenesisAssets.getAsset('freakyMenu', MUSIC));
        
        scrollMenu = GenesisAssets.getAsset('menus/scrollMenu', SOUND);
        cancelMenu = GenesisAssets.getAsset('menus/cancelMenu', SOUND);

        menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBGDesat', IMAGE));
        add(menuBG);

        songList = new FlxTypedGroup<Alphabet>();
        add(songList);

        iconList = new FlxTypedGroup<HealthIcon>();
        add(iconList);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(GenesisAssets.getAsset('vcr.ttf', FONT), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

        var assetsJson:SongListJson = Json.parse(Assets.getText('assets/data/freeplaySongs.json'));
        
        #if !debug
        for(song in assetsJson.songs)
        {
            if(song.debugOnly)
                assetsJson.songs.remove(song);
        }
        #end

        for(i in 0...assetsJson.songs.length)
        {
            var song = assetsJson.songs[i];

            addSong(i, song.name, song.icon, song.color);
            songs.push(song);
        }

        changeSelection();
    }

    var physicsUpdateTimer:Float = 0;

    function physicsUpdate()
    {
        menuBG.color = FlxColor.interpolate(menuBG.color, FlxColor.fromString(songs[curSelected].color), 0.045);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        physicsUpdateTimer += elapsed;
        if(physicsUpdateTimer > 1 / 60)
        {
            physicsUpdate();
            physicsUpdateTimer = 0;
        }

        intendedScore = Highscore.getScore(songs[curSelected].name.toLowerCase(), songs[curSelected].difficulties[curDifficulty]);

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();

        if(Controls.isPressed("BACK", JUST_PRESSED))
        {
            FlxG.sound.play(cancelMenu);
            States.switchState(this, new MainMenu());
        }

        if(Controls.isPressed("UI_UP", JUST_PRESSED))
            changeSelection(-1);

        if(Controls.isPressed("UI_DOWN", JUST_PRESSED))
            changeSelection(1);

        if(Controls.isPressed("UI_LEFT", JUST_PRESSED))
            changeDiff(-1);

        if(Controls.isPressed("UI_RIGHT", JUST_PRESSED))
            changeDiff(1);

        if(Controls.isPressed("ACCEPT", JUST_PRESSED))
        {
            GenesisAssets.keyedAssets.clear();
            
            PlayState.SONG = SongLoader.loadJSON(songs[curSelected].name.toLowerCase(), songs[curSelected].difficulties[curDifficulty]);
            States.switchState(this, new PlayState());
        }
    }

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
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

        changeDiff();
    }

    function changeDiff(change:Int = 0)
    {
        curDifficulty += change;
        if(curDifficulty < 0)
            curDifficulty = songs[curSelected].difficulties.length - 1;
        if(curDifficulty > songs[curSelected].difficulties.length - 1)
            curDifficulty = 0;

		PlayState.curDifficulty = songs[curSelected].difficulties[curDifficulty];
		diffText.text = '< ' + PlayState.curDifficulty.toUpperCase() + ' >';
		positionHighscore();
    }
}

typedef FreeplaySong =
{
    var name:String;
    var icon:String;
    var color:String;
    var difficulties:Array<String>;
    var debugOnly:Bool;
}

typedef SongListJson =
{
    var songs:Array<FreeplaySong>;
}