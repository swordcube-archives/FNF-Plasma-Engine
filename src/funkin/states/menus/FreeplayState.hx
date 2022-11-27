package funkin.states.menus;

import funkin.scripting.events.StateCreationEvent;
import funkin.scripting.Script;
import flixel.tweens.FlxEase;
import openfl.media.Sound;
import sys.thread.Mutex;
import sys.thread.Thread;
import funkin.ui.HealthIcon;
import funkin.ui.Alphabet;
import flixel.tweens.FlxTween;
import funkin.system.ChartParser;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class FreeplayState extends FNFState {
	public var songs:Array<SongMetadata> = [];

	public var curSelected:Int = 0;
	public var curDifficulty:Int = 1;
	public var curSongPlaying:Int = -1;

	public var songThread:Thread;
	public var threadActive:Bool = true;
	public var mutex:Mutex;
	public var songToPlay:Sound;

	public var scoreText:FlxText;
	public var diffText:FlxText;
	public var lerpScore:Float = 0;
	public var intendedScore:Int = 0;

	public var grpSongs:FlxTypedGroup<Alphabet>;
	public var curPlaying:Bool = false;

	public var iconArray:Array<HealthIcon> = [];

	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;

	public var colorTween:FlxTween;
	public var scoreBG:FlxSprite;
	public var bg:FlxSprite;

	override function create() {
		super.create();

		script = Script.load(Paths.script('data/states/FreeplayState'));
		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('menuMusic')));
		script.run(false);
		var event = script.event("onStateCreation", new StateCreationEvent(this));

		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordRPC.changePresence("In the Freeplay Menu", null);
		#end

		if(!event.cancelled) {
			var data = new haxe.xml.Access(Xml.parse(Assets.load(TEXT, Paths.xml("data/freeplaySongs"))).firstElement());
			for (song in data.nodes.song) {
				var bpm:Null<Float> = song.has.bpm ? Std.parseFloat(song.att.bpm) : null;
				addSong(song.att.name, CoolUtil.trimArray(song.att.difficulties.split(",")), song.att.character, FlxColor.fromString(song.att.bgColor), song.att.chartType, bpm);
			}

			mutex = new Mutex();

			bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image('menus/menuBGDesat')));
			bg.scrollFactor.set();
			add(bg);

			grpSongs = new FlxTypedGroup<Alphabet>();
			add(grpSongs);

			for (i in 0...songs.length) {
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, Bold, songs[i].songName);
				songText.isMenuItem = true;
				songText.targetY = i;
				songText.scrollFactor.set();
				grpSongs.add(songText);

				var icon:HealthIcon = new HealthIcon().loadIcon(songs[i].songCharacter);
				icon.tracked = songText;
				icon.scrollFactor.set();
				iconArray.push(icon);
				add(icon);
			}

			scoreText = new FlxText(0, 5, 0, "", 32);
			scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			scoreText.scrollFactor.set();

			scoreBG = new FlxSprite(0, 0).makeGraphic(1, 66, 0xFF000000);
			scoreBG.alpha = 0.6;
			scoreBG.scrollFactor.set();
			add(scoreBG);

			diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
			diffText.font = scoreText.font;
			diffText.scrollFactor.set();
			add(diffText);

			add(scoreText);

			var smallBannerBG = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 1, 0xFF000000);
			smallBannerBG.alpha = 0.6;
			smallBannerBG.scrollFactor.set();

			var smallBannerText = new FlxText(5, FlxG.height, 0, "Press TAB to switch mods / Press SHIFT to change gameplay modifiers", 17);
			smallBannerText.setFormat(Paths.font("vcr.ttf"), 17, FlxColor.WHITE, RIGHT);
			smallBannerText.y -= smallBannerText.height + 5;
			smallBannerText.scrollFactor.set();

			smallBannerBG.scale.y = smallBannerText.height + 5;
			smallBannerBG.updateHitbox();
			smallBannerBG.y -= smallBannerBG.height;

			add(smallBannerBG);
			add(smallBannerText);

			changeSelection();
			changeDiff();
		} else runDefaultCode = false;

		var event = script.event("onStateCreationPost", new StateCreationEvent(this));
	}

	public function addSong(songName:String, difficulties:Array<String>, songCharacter:String, bgColor:Null<FlxColor>, ?chartType:Null<ChartType>, ?bpm:Null<Float>) {
		songs.push(new SongMetadata(songName, difficulties, songCharacter, bgColor, chartType, null));
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;
		Conductor.position = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		lerpScore = CoolUtil.fixedLerp(lerpScore, intendedScore, 0.4);

		if (curSongPlaying > -1) {
			var lerp = FlxMath.lerp(1.15, 1, FlxEase.cubeOut(Conductor.curBeatFloat % 1));
			iconArray[curSongPlaying].scale.set(lerp, lerp);
		}

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		positionHighscore();

		if (FlxG.keys.justPressed.SHIFT)
			openSubState(new funkin.substates.GameplayModifiers());

		if (controls.getP("UI_UP")) changeSelection(-1);
		if (controls.getP("UI_DOWN")) changeSelection(1);

		if (controls.getP("UI_LEFT")) changeDiff(-1);
		if (controls.getP("UI_RIGHT")) changeDiff(1);

		if (controls.getP("BACK")) {
			threadActive = false;
			FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.getP("ACCEPT"))
			loadSong(songs[curSelected].chartType, songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty]);

		mutex.acquire();
		if (songToPlay != null) {
			FlxG.sound.playMusic(songToPlay);
			if (FlxG.sound.music.fadeTween != null) FlxG.sound.music.fadeTween.cancel();
			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);
			FlxG.sound.music.pitch = PlayerSettings.prefs.get("Playback Rate");
			Conductor.bpm = songs[curSelected].bpm;
			songToPlay = null;
		}
		mutex.release();
	}

	function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffText.x = scoreBG.x + scoreBG.width / 2;
		diffText.x -= diffText.width / 2;
	}

	public function loadSong(chartType:ChartType, name:String, diff:String) {
		if(!FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff'))) {
			openSubState(new funkin.substates.ErrorSubState(
				ERROR,
				"Chart not found!",
				'The chart for $name on $diff difficulty doesn\'t exist!'
			));
			return Console.error('The chart for $name on $diff difficulty doesn\'t exist!');
		}
		threadActive = false;
		Conductor.rate = PlayerSettings.prefs.get("Playback Rate");
		PlayState.isStoryMode = false;
		PlayState.SONG = ChartParser.loadSong(chartType, name, diff);
		PlayState.curDifficulty = diff;
		FlxG.switchState(new PlayState());
	}

	function changeDiff(change:Int = 0) {
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, songs[curSelected].difficulties.length-1);
		intendedScore = Highscore.getScore(songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty]);

		var arrowThings:Array<String> = songs[curSelected].difficulties.length > 1 ? ["< ", " >"] : ["", ""];
		diffText.text = arrowThings[0]+songs[curSelected].difficulties[curDifficulty].toUpperCase()+arrowThings[1];
		positionHighscore();

		#if discord_rpc
		DiscordRPC.changePresence(
			"In the Freeplay Menu", 
			"Selecting "+songs[curSelected].songName+" on "+songs[curSelected].difficulties[curDifficulty]
		);
		#end
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Assets.load(SOUND, Paths.sound('menus/scrollMenu')));

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);

		intendedScore = Highscore.getScore(songs[curSelected].songName, songs[curSelected].difficulties[curDifficulty]);

		var bullShit:Int = 0;
		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			item.alpha = curSelected == bullShit ? 1 : 0.6;
			bullShit++;
		}

		if(colorTween != null) colorTween.cancel();
		colorTween = FlxTween.color(bg, 0.45, bg.color, songs[curSelected].bgColor, {ease: FlxEase.cubeOut});

		changeDiff();
		changeSongPlaying();
	}

	function changeSongPlaying() {
		if(songThread == null) {
			songThread = Thread.create(function() {
				while (true) {
					if (!threadActive) return;
					var index:Null<Int> = Thread.readMessage(false);
					if (index != null) {
						if (index == curSelected && index != curSongPlaying) {
							var inst:Sound = Assets.load(SOUND, Paths.inst(songs[curSelected].songName));
							if (index == curSelected && threadActive) {
								if(curSongPlaying > -1) iconArray[curSongPlaying].scale.set(1,1);
								mutex.acquire();
								songToPlay = inst;
								mutex.release();
								curSongPlaying = curSelected;
							}
						}
					}
				}
			});
		}
		songThread.sendMessage(curSelected);
	}
}

class SongMetadata {
	public var songName:String = "";
	public var difficulties:Array<String> = [];
	public var songCharacter:String = "";
	public var bgColor:FlxColor = FlxColor.WHITE;
	public var chartType:ChartType = VANILLA;
	public var bpm:Float = 100.0;

	public function new(song:String, difficulties:Array<String>, songCharacter:String, bgColor:Null<FlxColor>, ?chartType:Null<ChartType>, ?bpm:Null<Float>) {
		if(difficulties == null) difficulties = ["easy", "normal", "hard"];
		if(bgColor == null) bgColor = FlxColor.WHITE;
		if(chartType == null) chartType = VANILLA;
		if(bpm == null) {
			var json:Song = null; // has to be initialized to be used!!!!!!
			try {
				var temp:Dynamic = Json.parse(Assets.load(TEXT, Paths.json('songs/${song.toLowerCase()}/${difficulties[0]}')));
				json = temp.song;
			} catch(e) {
				Console.error("Error occured while loading JSON! "+e.toString());
			}
			if(json != null)
				bpm = json.bpm;
			else
				bpm = 100.0;
		}
		this.songName = song;
		this.difficulties = difficulties;
		this.songCharacter = songCharacter;
		this.bgColor = bgColor;
		this.chartType = chartType;
		this.bpm = bpm;
	}
}
