package funkin.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.game.FunkinState;
import funkin.game.PlayState;
import funkin.game.Song;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;
import funkin.ui.Alphabet;
import funkin.ui.HealthIcon;

using StringTools;
#if MODS_ALLOWED
import funkin.game.GlobalVariables;
import funkin.ui.menus.ModSelector;
#end

typedef FreeplaySongData = {
    var songName:String;
    var icon:String;
    var bgColor:String;
    var difficulties:Array<String>;
    var songBPM:Float;
};

class FreeplayMenu extends FunkinState
{
    static var curSelected:Int = 0;
    static var curDifficulty:Int = 1;
    
    var menuBG:FlxSprite;
    var songs:FlxTypedGroup<FreeplaySongUI>;
    
    var songList:Array<FreeplaySongData> = [];

	var scrollMenu:Dynamic;
	var confirmMenu:Dynamic;
	var cancelMenu:Dynamic;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

    #if MODS_ALLOWED
    var modSelector:ModSelector;
    #end

    var vocals:FlxSound = new FlxSound();
    
    override public function create()
    {
        super.create();

        FlxG.sound.list.add(vocals);

		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			FlxG.sound.playMusic(FunkinAssets.getSound(Paths.music('freakyMenu')));

		scrollMenu = FunkinAssets.getSound(Paths.sound('menus/scrollMenu'));
		confirmMenu = FunkinAssets.getSound(Paths.sound('menus/confirmMenu'));
		cancelMenu = FunkinAssets.getSound(Paths.sound('menus/cancelMenu'));

		menuBG = new FlxSprite().loadGraphic(FunkinAssets.getImage(Paths.image('menus/menuBGDesat')));
		menuBG.antialiasing = Preferences.getOption("antiAliasing");
		add(menuBG);

        songs = new FlxTypedGroup<FreeplaySongUI>();
        add(songs);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

        add(scoreText);

        loadSongs();

        #if MODS_ALLOWED
        modSelector = new ModSelector();
        modSelector.onChangeSelection = function() {
            loadSongs();
        };
        add(modSelector);
        #end

        updateScore();
    }

    function loadSongs()
    {
        curSelected = 0;
        
        songList = [];

        var mod:String = #if MODS_ALLOWED softmod.SoftMod.modsList[GlobalVariables.selectedMod]; #else vanillaGameName; #end

        var rawSongList:Array<String> = FunkinAssets.getText(Paths.txt("data/freeplaySongs"), mod).split("\n");
        for(thing in rawSongList)
        {
            var item:Array<String> = thing.split(":");
            //Reference:
            //Test:bf-pixel:#68b1e8:normal:150
            songList.push({
                songName: item[0].trim(),
                icon: item[1].trim(),
                bgColor: item[2].trim(),
                difficulties: item[3].split(","),
                songBPM: Std.parseFloat(item[4].trim()),
            });
        }

        songs.forEachAlive(function(song:FreeplaySongUI){
            songs.remove(song, true);
            song.kill();
            song.destroy();
        });
        songs.clear();

        for(i in 0...songList.length)
        {
            var song:FreeplaySongData = songList[i];
            var newSongUI:FreeplaySongUI = new FreeplaySongUI(0, (70 * i) + 30, i, song.songName, song.icon);
            songs.add(newSongUI);
        }

        changeSelection();
    }

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}

    var menuBGColor:Array<Float> = [
        255,
        255,
        255,
    ];
    
    function updateScore()
    {
		#if MODS_ALLOWED
		var songNameForScoreLol:String = songList[curSelected].songName.toLowerCase()+"-"+softmod.SoftMod.modsList[GlobalVariables.selectedMod];
		#else
		var songNameForScoreLol:String = songList[curSelected].songName.toLowerCase();
		#end
        
        intendedScore = Highscore.getScore(songNameForScoreLol, songList[curSelected].difficulties[curDifficulty].trim());

		lerpScore = FlxMath.lerp(lerpScore, intendedScore, delta * 7);

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();
    }

    var curPlaying:String = "";
    var hasVoices:Bool = false;

    override public function update(elapsed:Float)
    {
        updateScore();

        var bgColorSpeed:Float = delta * 2;
        var lerpValues:Array<Float> = [
            FlxMath.lerp(menuBGColor[0], FlxColor.fromString(songList[curSelected].bgColor).red, bgColorSpeed),
            FlxMath.lerp(menuBGColor[1], FlxColor.fromString(songList[curSelected].bgColor).green, bgColorSpeed),
            FlxMath.lerp(menuBGColor[2], FlxColor.fromString(songList[curSelected].bgColor).blue, bgColorSpeed),
        ];

        menuBGColor = [
            lerpValues[0],
            lerpValues[1],
            lerpValues[2],
        ];

        menuBG.color = FlxColor.fromRGB(Std.int(lerpValues[0]), Std.int(lerpValues[1]), Std.int(lerpValues[2]));

        if(FlxG.sound.music != null && FlxG.sound.music.playing)
            Conductor.position = FlxG.sound.music.time;

        super.update(elapsed);

        if(UIControls.justPressed("BACK"))
        {
            FlxG.sound.music.stop();
            vocals.stop();
            
            FlxG.sound.play(cancelMenu);
            switchState(new MainMenu());
        }

        if(FlxG.keys.justPressed.SPACE && curPlaying != songList[curSelected].songName)
        {
            hasVoices = FunkinAssets.exists(Paths.voices(songList[curSelected].songName));

            Conductor.changeBPM(songList[curSelected].songBPM);
            
            curPlaying = songList[curSelected].songName;

            FlxG.sound.music.stop();
            vocals.stop();
            
            FlxG.sound.playMusic(FunkinAssets.getSound(Paths.inst(songList[curSelected].songName)), 0);
            if(hasVoices)
                vocals.loadEmbedded(FunkinAssets.getSound(Paths.voices(songList[curSelected].songName)));

            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;
            FlxG.sound.music.play();

            FlxG.sound.music.fadeIn(1, 0, 1);

            if(hasVoices)
            {
                vocals.time = 0;
                vocals.volume = 0;
                vocals.play();
                vocals.fadeIn(1, 0, 1);
            }
        }
        else if(UIControls.justPressed("ACCEPT"))
        {
            FlxG.sound.music.stop();
            vocals.stop();
            
            PlayState.songJSON = SongLoader.getJSON(songList[curSelected].songName, songList[curSelected].difficulties[curDifficulty].trim());
            switchState(new PlayState());
        }

        #if MODS_ALLOWED
        if(!FlxG.keys.checkStatus(modSelector.ctrlKey, JUST_PRESSED) && UIControls.justPressed("LEFT"))
            changeDiff(-1);

        if(!FlxG.keys.checkStatus(modSelector.ctrlKey, JUST_PRESSED) && UIControls.justPressed("RIGHT"))
            changeDiff(1);
        #else
        if(UIControls.justPressed("LEFT"))
            changeDiff(-1);

        if(UIControls.justPressed("RIGHT"))
            changeDiff(1);
        #end

        if(UIControls.justPressed("UP"))
            changeSelection(-1);

        if(UIControls.justPressed("DOWN"))
            changeSelection(1);
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;
        if(curSelected < 0)
            curSelected = songs.members.length-1;
        if(curSelected > songs.members.length-1)
            curSelected = 0;

        var i:Int = 0;
        songs.forEachAlive(function(song:FreeplaySongUI) {
            song.targetY = i-curSelected;
            song.alphabet.alpha = song.targetY == 0 ? 1 : 0.6;
            i++;
        });

        FlxG.sound.play(scrollMenu);
        changeDiff();
    }

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (curDifficulty < 0)
			curDifficulty = songList[curSelected].difficulties.length - 1;
		if (curDifficulty > songList[curSelected].difficulties.length - 1)
			curDifficulty = 0;

		PlayState.curDifficulty = songList[curSelected].difficulties[curDifficulty].trim();
		diffText.text = '< ' + PlayState.curDifficulty.toUpperCase() + ' >';
		positionHighscore();
	}

    override public function beatHit()
    {
        super.beatHit();
        
        var song:FreeplaySongUI = songs.members[curSelected];
        if(song.targetY == 0 && song.songName == curPlaying)
            song.icon.scale.set(1.2, 1.2);
    }

    override public function stepHit()
    {
        super.stepHit();
        
        if(hasVoices)
        {
            if(!(Conductor.isAudioSynced(FlxG.sound.music) && Conductor.isAudioSynced(vocals)))
            {
                FlxG.sound.music.pause();
                vocals.pause();

                FlxG.sound.music.time = Conductor.position;
                vocals.time = Conductor.position;

                FlxG.sound.music.play();
                vocals.play();
            }
        }
        else
        {
            if(!Conductor.isAudioSynced(FlxG.sound.music))
            {
                FlxG.sound.music.pause();
                FlxG.sound.music.time = Conductor.position;
                FlxG.sound.music.play();
            }
        }
    }
}

class FreeplaySongUI extends FlxGroup
{
    public var targetY:Int = 0;
    public var alphabet:Alphabet;
    public var icon:HealthIcon;
    public var songName:String = "";

    public function new(x:Float, y:Float, targetY:Int, songName:String = "Test", icon:String = "bf")
    {
        super();

        alphabet = new Alphabet(x, y, songName, true);
        alphabet.isMenuItem = true;
        add(alphabet);
        
        this.songName = songName;
        this.targetY = targetY;
        this.icon = new HealthIcon(icon);
        this.icon.sprTracker = alphabet;
        add(this.icon);
    }

    override public function update(elapsed:Float)
    {
        alphabet.targetY = targetY;
        super.update(elapsed);

        var curState:Dynamic = FlxG.state;
        var scale:Float = FlxMath.lerp(icon.scale.x, 1, curState.delta * 9.6);
        icon.scale.set(scale, scale);
    }
}