package funkin.states.editors.charter;

import flixel.math.FlxMath;
import funkin.system.FNFSprite;
import funkin.system.ChartParser;
import flixel.FlxSprite;

using StringTools;

class ChartingState extends Editor {
	public var SONG:Song;

	final gridSize:Int = 40;

	var gridGroup:CharterGrid;

	public var curSection:Int = 0;
	public var currentNoteType:String = "Default";

	override function create() {
		super.create();

		// Controls what happens when you press enter or space.
		onAccept.add(function() {
			FlxG.switchState(new PlayState());
		});

		// Load the song data
		if(PlayState.SONG != null)
			SONG = PlayState.SONG;
		else
			SONG = ChartParser.loadSong(AUTO, "test");

		// Fancyness!!! (real)
		var bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGNeo"));
		bg.alpha = 0.25;
		add(bg);

		// Create grid
		gridGroup = new CharterGrid(SONG.keyAmount, SONG.sections[0].lengthInSteps);
		add(gridGroup);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(controls.getP("UI_LEFT")) {
			curSection = Std.int(FlxMath.bound(curSection - 1, 0, SONG.sections.length-1));
			gridGroup.onChangeSection.dispatch(curSection);
		}

		if(controls.getP("UI_RIGHT")) {
			curSection = Std.int(FlxMath.bound(curSection + 1, 0, SONG.sections.length-1));
			gridGroup.onChangeSection.dispatch(curSection);
		}
	}
}