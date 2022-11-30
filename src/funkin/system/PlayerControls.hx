package funkin.system;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

using StringTools;

class PlayerControls {
    var playerID:Int = 1;
    public final default_list:Map<String, Array<FlxKey>> = [
        // UI
        "UI_UP"     => [W, UP],
        "UI_DOWN"   => [S, DOWN],
        "UI_LEFT"   => [A, LEFT],
        "UI_RIGHT"  => [D, RIGHT],

        "PAUSE"     => [ENTER, NONE],
        "BACK"      => [BACKSPACE, ESCAPE],
        "ACCEPT"    => [ENTER, SPACE],

        // Gameplay
        "GAME_1"    => [SPACE],
        "GAME_2"    => [D, K],
        "GAME_3"    => [D, SPACE, K],
        "GAME_4"    => [D, F, J, K],
        "GAME_5"    => [D, F, SPACE, J, K],
        "GAME_6"    => [S, D, F, J, K, L],
        "GAME_7"    => [S, D, F, SPACE, J, K, L],
        "GAME_8"    => [A, S, D, F, H, J, K, L],
        "GAME_9"    => [A, S, D, F, SPACE, H, J, K, L],
    ];
    public var list:Map<String, Array<Null<FlxKey>>> = [];
    
    public function new(playerID:Int = 1) {
        this.playerID = playerID;

        var flush:Bool = false;
        for(key in default_list.keys()) {
            var saveDataCtrlName:String = 'player${playerID}_CONTROL_$key';
            var saveData:Array<Null<FlxKey>> = Reflect.getProperty(FlxG.save.data, saveDataCtrlName);
            if(saveData != null) list[key] = saveData;
            else {
                flush = true;
                list[key] = default_list[key];
                Reflect.setProperty(FlxG.save.data, saveDataCtrlName, default_list[key]);
                Console.debug('Set player control: ${key} to ${default_list[key]}');
            }
            Console.debug('Loaded player control: ${key} successfully!');
        }
        if(flush) FlxG.save.flush();
    }

    public function get(name:String, ?direction:Int = 0) {
        if(!list.exists(name)) {
            Console.debug('Control with the name of: $name doesn\'t exist! Names are case-sensitive, so try checking that out first.');
            return false;
        }

        var status:FlxInputState = PRESSED;

        if(name.startsWith("GAME_")) {
            var arrowKeys:Array<FlxKey> = [FlxKey.LEFT, FlxKey.DOWN, FlxKey.UP, FlxKey.RIGHT];
            return FlxG.keys.checkStatus(list[name][direction], status) || FlxG.keys.checkStatus(arrowKeys[direction % 4], status);
        }
        
        // Otherwise check if the alt bind isn't null or set to none
        // If it isn't null or none, return if the regular OR alt bind is pressed
        if(list[name][1] != null && list[name][1] != NONE)
            return FlxG.keys.checkStatus(list[name][0], status) || FlxG.keys.checkStatus(list[name][1], status);

        return (list[name][0] == null || list[name][0] == NONE) ? false : FlxG.keys.checkStatus(list[name][0], status);
    }

    public function getP(name:String, ?direction:Int = 0) {
        if(!list.exists(name)) {
            Console.debug('Control with the name of: $name doesn\'t exist! Names are case-sensitive, so try checking that out first.');
            return false;
        }

        var status:FlxInputState = JUST_PRESSED;

        if(name.startsWith("GAME_")) {
            var arrowKeys:Array<FlxKey> = [FlxKey.LEFT, FlxKey.DOWN, FlxKey.UP, FlxKey.RIGHT];
            return FlxG.keys.checkStatus(list[name][direction], status) || FlxG.keys.checkStatus(arrowKeys[direction % 4], status);
        }
        
        // Otherwise check if the alt bind isn't null or set to none
        // If it isn't null or none, return if the regular OR alt bind is pressed
        if(list[name][1] != null && list[name][1] != NONE)
            return FlxG.keys.checkStatus(list[name][0], status) || FlxG.keys.checkStatus(list[name][1], status);

        return (list[name][0] == null || list[name][0] == NONE) ? false : FlxG.keys.checkStatus(list[name][0], status);
    }

    public function getR(name:String, ?direction:Int = 0) {
        if(!list.exists(name)) {
            Console.debug('Control with the name of: $name doesn\'t exist! Names are case-sensitive, so try checking that out first.');
            return false;
        }

        var status:FlxInputState = JUST_RELEASED;

        if(name.startsWith("GAME_")) {
            var arrowKeys:Array<FlxKey> = [FlxKey.LEFT, FlxKey.DOWN, FlxKey.UP, FlxKey.RIGHT];
            return FlxG.keys.checkStatus(list[name][direction], status) || FlxG.keys.checkStatus(arrowKeys[direction % 4], status);
        }
        
        // Otherwise check if the alt bind isn't null or set to none
        // If it isn't null or none, return if the regular OR alt bind is pressed
        if(list[name][1] != null && list[name][1] != NONE)
            return FlxG.keys.checkStatus(list[name][0], status) || FlxG.keys.checkStatus(list[name][1], status);

        return (list[name][0] == null || list[name][0] == NONE) ? false : FlxG.keys.checkStatus(list[name][0], status);
    }

    public function set(name:String, keys:Array<Null<FlxKey>>) {
        // If this bind is a gameplay bind, fuck off
        // Gameplay binds are handled elsewhere
        if(name.startsWith("GAME_")) return;

        // Otherwise set the control correctly asnfd syudvisgufh
        list[name] = keys;
    }

    public function flush() {
        for(name=>keys in list) {
            var saveDataCtrlName:String = 'player${playerID}_CONTROL_$name';
            Reflect.setProperty(FlxG.save.data, saveDataCtrlName, keys);
        }
        FlxG.save.flush();
    }
}