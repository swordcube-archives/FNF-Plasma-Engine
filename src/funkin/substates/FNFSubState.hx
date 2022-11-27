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

	override function update(elapsed:Float) {
		super.update(elapsed);

		#if debug
		if(FlxG.keys.justPressed.F3) FlxG.resetState();
		#end
	}

	override public function add(obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.add(obj);
	}
}