package funkin.system;

/**
 * The class controlling what set of preferences and controls are loaded.
 * 
 * Access preferences or controls using:
 * ```haxe
 * PlayerSettings.prefs.get("something")
 * ```
 * or
 * ```haxe
 * PlayerSettings.controls.get("ACCEPT") // gets if a control is pressed
 * PlayerSettings.controls.getP("ACCEPT") // gets if a control was just pressed
 * PlayerSettings.controls.getR("ACCEPT") // gets if a control was just released
 * ```
 */
class PlayerSettings {
    public static var controls:PlayerControls;
    public static var prefs:PlayerPrefs;

    public static var playerID(default, set):Int;

    static function set_playerID(v:Int):Int {
        if(v < 1) {
            Console.warn('Cannot load prefs for a Player with an ID less than 1!');
            v = 1;
        }
        reload(v);
		return playerID = v;
	}

    public static function reload(?playerID:Null<Int>) {
        if (playerID == null) playerID = FlxG.save.data.playerID;
        controls = new PlayerControls(playerID);
        prefs = new PlayerPrefs(playerID);
        Console.debug('Reloaded settings for Player $playerID!');
    }

    public static function init(ID:Int = 1) {
        playerID = ID;
    }
}