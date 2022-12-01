package funkin.states.menus;

import funkin.scripting.events.StateCreationEvent;
import funkin.scripting.Script;
import funkin.system.ChartParser;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import funkin.ui.UIArrow;
import funkin.system.FNFSprite;
import flixel.math.FlxMath;
import funkin.ui.WeekItem;
import haxe.xml.Access;
import funkin.system.ChartParser.ChartType;
import funkin.ui.StoryCharacter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;

using StringTools;

@:dox(hide)
typedef StorySong = {
	var name:String;
	var chartType:ChartType;
}

@:dox(hide)
typedef StoryWeek = {
	var texture:String;
	var name:String;
	var characters:Array<String>;
	var difficulties:Array<String>;
	var songs:Array<StorySong>;
}

class StoryMenuState extends FNFState {
	public var scoreText:FlxText;
	public var titleText:FlxText;

	public var grpCharacters:FlxTypedGroup<StoryCharacter>;
	public var grpWeeks:FlxTypedGroup<WeekItem>;

	public var weekList:Array<StoryWeek> = [];
	public var arrows:Array<UIArrow> = [];
	public var sprDifficulty:FlxSprite;
	
	public var curSelected:Int = 0;
	public var curDifficulty:Int = 1;

	public var trackListTxt:FlxText;

	public var lerpScore:Float = 0;
	public var intendedScore:Int = 0;

	public var confirmed:Bool = false;

	public var script:ScriptModule;
	public var runDefaultCode:Bool = true;
	
	override function create() {
		super.create();
		enableTransitions();

		weekList = getWeekList();

		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)) {
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('menuMusic')));
			Conductor.bpm = 102;
		}

		persistentUpdate = persistentDraw = true;

		script = Script.load(Paths.script('data/states/MainMenuState'));
		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)) {
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('menuMusic')));
			Conductor.bpm = 102;
		}
		script.setParent(this);
		script.run(false);
		var event = script.event("onStateCreation", new StateCreationEvent(this));

		if(!event.cancelled) {
			scoreText = new FlxText(10, 10, 0, "PLACEHOLDER SCORE", 32);
			scoreText.setFormat(Paths.font("vcr.ttf"), 32);

			titleText = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
			titleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
			titleText.alpha = 0.7;

			add(grpWeeks = new FlxTypedGroup<WeekItem>());
			var bgStrip = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
			add(bgStrip);

			add(grpCharacters = new FlxTypedGroup<StoryCharacter>());
			for(i in 0...3) {
				var weekCharacters:Array<String> = weekList[curSelected].characters;
				grpCharacters.add(new StoryCharacter((FlxG.width * 0.25) * (1 + i) - 150, 70, weekCharacters[i]));
			}

			for(i in 0...weekList.length) {
				var week:StoryWeek = weekList[i];

				var weekThing = new WeekItem(0, bgStrip.y + bgStrip.height + 10, week.texture);
				weekThing.y += ((weekThing.height + 20) * i);
				weekThing.targetY = i;
				weekThing.screenCenter(X);
				weekThing.alpha = 0.6;
				grpWeeks.add(weekThing);
			}
	
			add(new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK));
			add(scoreText);
			add(titleText);

			var tracksSprite = new FNFSprite(FlxG.width * 0.07, bgStrip.y + 425).load("IMAGE", Paths.image('ui/tracksText'));
			add(tracksSprite);

			trackListTxt = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
			trackListTxt.alignment = CENTER;
			trackListTxt.font = scoreText.font;
			trackListTxt.color = 0xFFe55777;
			add(trackListTxt);

			var arrow = new UIArrow(grpWeeks.members[0].x + (grpWeeks.members[0].width + 10), grpWeeks.members[0].y + 10);
			arrow.control = "UI_LEFT";
			arrow.onJustPressed = function() {
				if(confirmed) return;
				arrow.playAnim("press");
				changeDifficulty(-1);
			};
			arrows.push(arrow);
			add(arrow);

			sprDifficulty = new FlxSprite(0, arrow.y);
			add(sprDifficulty);

			var arrow = new UIArrow(arrow.x + 376, arrow.y, true);
			arrow.control = "UI_RIGHT";
			arrow.onJustPressed = function() {
				if(confirmed) return;
				arrow.playAnim("idle");
				changeDifficulty(1);
			};
			arrows.push(arrow);
			add(arrow);

			changeSelection();
		} else runDefaultCode = false;

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);

		script.event("onStateCreationPost", new StateCreationEvent(this));
	}

	inline function changeSelection(?change:Int = 0) {
		FlxG.sound.play(Assets.load(SOUND, Paths.sound('menus/scrollMenu')));

		grpWeeks.members[curSelected].alpha = 0.6;
		curSelected = Std.int(FlxMath.wrap(curSelected + change, 0, grpWeeks.length-1));
		grpWeeks.members[curSelected].alpha = 1;

		titleText.text = weekList[curSelected].name;
		titleText.x = FlxG.width - (titleText.width + 10);

		var i:Int = 0;
		grpWeeks.forEach(function(week:WeekItem) {
			week.targetY = i - curSelected;
			i++;
		});
		i = 0;
		for(char in grpCharacters.members) {
			char.loadCharacter(weekList[curSelected].characters[i]);
			i++;
		}

		updateTracks();
		changeDifficulty();
	}

	var tweenDifficulty:FlxTween;
	inline function changeDifficulty(?change:Int = 0) {
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, weekList[curSelected].difficulties.length-1);
		intendedScore = Highscore.getScore(weekList[curSelected].texture, weekList[curSelected].difficulties[curDifficulty]);

		var newImage:FlxGraphic = Assets.load(IMAGE, Paths.image('menus/story/difficulties/${weekList[curSelected].difficulties[curDifficulty]}'));
		if(sprDifficulty.graphic != newImage) {
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = arrows[0].x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = arrows[0].y - 15;

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: arrows[0].y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween) {
				tweenDifficulty = null;
			}});
		}
	}

	inline function updateTracks() {
		var tracks:String = "";

		for(track in weekList[curSelected].songs)
			tracks += '${track.name.toUpperCase()}\n';

		trackListTxt.text = tracks;
		trackListTxt.screenCenter(X);
		trackListTxt.x -= FlxG.width * 0.35;
	}

	function beatHit(beat:Int) {
		for(func in ["onBeatHit", "beatHit"]) script.call(func, [beat]);	
		for(character in grpCharacters.members)
			character.dance();
		for(func in ["onBeatHit", "beatHit"]) script.call(func+"Post", [beat]);	
	}

	function stepHit(step:Int) {
		for(func in ["onStepHit", "stepHit"]) {
			script.call(func, [step]);
			script.call(func+"Post", [step]);
		}
	}

    override function update(elapsed:Float) {
		for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);

		super.update(elapsed);

		if(runDefaultCode) {
			lerpScore = CoolUtil.fixedLerp(lerpScore, intendedScore, 0.4);
			scoreText.text = "WEEK SCORE:" + Math.round(lerpScore);
	
			if (FlxG.sound.music != null)
				Conductor.position = FlxG.sound.music.time;
	
			if(controls.getP("UI_UP") && !confirmed) changeSelection(-1);
			if(controls.getP("UI_DOWN") && !confirmed) changeSelection(1);
	
			if(controls.getP("BACK") && !confirmed) {
				FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
				FlxG.switchState(new funkin.states.menus.MainMenuState());
			}
	
			if(controls.getP("ACCEPT") && !confirmed) {
				confirmed = true;
				PlayState.storyPlaylist = weekList[curSelected].songs;
				PlayState.isStoryMode = true;
				PlayState.storyScore = 0;
				PlayState.weekName = weekList[curSelected].texture;
				PlayState.curDifficulty = weekList[curSelected].difficulties[curDifficulty];
				Conductor.rate = 1.0;
				var initialSong = PlayState.storyPlaylist[0];
				PlayState.SONG = ChartParser.loadSong(initialSong.chartType, initialSong.name, PlayState.curDifficulty);
				grpCharacters.members[1].canDance = false;
				grpCharacters.members[1].playAnim("confirm");
				grpWeeks.members[curSelected].startFlashing();
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					FlxG.switchState(new PlayState());
				});
				FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
			}
		}

		for(func in ["onUpdate", "update"]) script.call(func+"Post", [elapsed]);
	}

	function getWeekList() {
		var returnList:Array<StoryWeek> = [];
		while(true) {
			// Load the intial XML Data.
			var xml:Xml = Xml.parse(Assets.load(TEXT, Paths.xml('data/storyWeeks'))).firstElement();
			if(xml == null) {
				Console.error('Occured while trying to load story mode weeks. | Either the XML doesn\'t exist or the "weeks" node is missing!');
				break;
			}

			var data:Access = new Access(xml);
			for(week in data.nodes.week) {
				var weekData:StoryWeek = {
					texture: week.att.texture,
					name: week.att.name,
					songs: [],
					difficulties: CoolUtil.trimArray(week.att.difficulties.split(",")),
					characters: CoolUtil.trimArray(week.att.chars.split(","))
				};
				for(song in week.nodes.song) {
					weekData.songs.push({
						name: song.att.name,
						chartType: song.att.chartType
					});
				}
				returnList.push(weekData);
			}

			break;
		}
		if(returnList.length < 1) returnList = [
			{
				texture: "tutorial",
				name: "ERROR LOADING WEEKS",
				songs: [
					{
						name: "tutorial",
						chartType: VANILLA
					}
				],
				difficulties: ["easy", "normal", "hard"],
				characters: ["", "bf", ""]
			}
		];

		return returnList;
	}

	override public function destroy() {
		script.call("onDestroy");
		script.call("destroy");
		script.destroy();
		super.destroy();
	}
}