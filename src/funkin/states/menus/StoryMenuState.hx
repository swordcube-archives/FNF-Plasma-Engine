package funkin.states.menus;

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
	public var grpCharacters:FlxTypedGroup<StoryCharacter>;
	public var grpWeeks:FlxTypedGroup<WeekItem>;

	public var weekList:Array<StoryWeek> = [];
	public var curSelected:Int = 0;
	
	override function create() {
		super.create();
		enableTransitions();

		weekList = getWeekList();

		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)) {
			FlxG.sound.playMusic(Assets.load(SOUND, Paths.music('menuMusic')));
			Conductor.bpm = 102;
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "PLACEHOLDER SCORE", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32);

		// i gotta add week titles later

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
			grpWeeks.add(weekThing);
		}
 
		add(new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK));
		add(scoreText);

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);
	}

	function beatHit(beat:Int) {
		for(character in grpCharacters.members)
			character.dance();
	}

	function stepHit(step:Int) {

	}

    override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.position = FlxG.sound.music.time;

		if(controls.getP("BACK")) {
			FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
			FlxG.switchState(new funkin.states.menus.MainMenuState());
		}
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
}