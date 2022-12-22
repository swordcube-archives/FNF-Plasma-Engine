package funkin.substates;

import flixel.FlxSprite;
import flixel.FlxBasic;
import funkin.system.PlayerPrefs;
import funkin.system.PlayerControls;
import flixel.FlxSubState;

// Dunno what i would need to add to this class
// But it's here just in case
class FNFSubState extends FlxSubState {
	public var controls(get, null):PlayerControls;
	function get_controls() {
		return PlayerSettings.controls;
	}

	public var prefs(get, null):PlayerPrefs;
	function get_prefs() {
		return PlayerSettings.prefs;
	}

	/**
	 * The current beat of the song.
	 */
	public var curBeat:Int;

	function get_curBeat():Int {
		return Conductor.curBeat;
	}

	/**
	 * The current step of the song.
	 */
	public var curStep:Int;

	function get_curStep():Int {
		return Conductor.curStep;
	}

	/**
	 * The current section of the song.
	 */
	public var curSection:Int;

	function get_curSection():Int {
		return Std.int(Conductor.curStep / 16);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if(FlxG.keys.justPressed.F3) FlxG.resetState();
	}

	override public function add(obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.add(obj);
	}
}