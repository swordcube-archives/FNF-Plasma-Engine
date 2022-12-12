package funkin.system;

import funkin.game.Note;

typedef PrefData = {
    var name:String;
    var value:Dynamic;
};

class PlayerPrefs {
    var playerID:Int = 1;
    final default_list:Map<String, Array<PrefData>> = [
        "Preferences" => [
            {
                name: "Downscroll",
                value: false
            },
            {
                name: "Centered Notes",
                value: false
            },
            {
                name: "Ghost Tapping",
                value: false
            },
            {
                name: "Allow Unsafe Mods",
                value: false
            },
            {
                name: "FPS Counter",
                value: true
            },
            {
                name: "Memory Counter",
                value: true
            },
            {
                name: "Version Display",
                value: true
            },
            {
                name: "Auto Pause",
                value: true
            },
            {
                name: "Miss Sounds",
                value: true
            },
            {
                name: "Framerate Cap",
                value: 240
            },
            {
                name: "Note Offset",
                value: 0
            }
        ],
        "Appearance" => [
            {
                name: "Antialiasing",
                value: true
            },
            {
                name: "Note Skin",
                value: "Arrows"
            },
            {
                name: "Judgement Camera",
                value: "World"
            },
            {
                name: "Judgement Counter",
                value: "Left"
            },
            {
                name: "Sustain Layering",
                value: "Above"
            },
            {
                name: "Enable Note Splashes",
                value: true
            },
            {
                name: "Flashing Lights",
                value: true
            },
            {
                name: "Fancy Console",
                value: true
            },
        ],

        // gameplay modifiers only appear in freeplay by
        // pressing shift, they will not appear in options
        "Gameplay Modifiers" => [
            {
                name: "Scroll Type",
                value: "Multiplier"
            },
            {
                name: "Scroll Speed",
                value: 0
            },
            {
                name: "Playback Rate",
                value: 1.0
            },
            {
                name: "Botplay",
                value: false
            },
            {
                name: "Play As Opponent",
                value: false
            }
        ]
    ];
    public var list:Map<String, Dynamic> = [];

    public function new(playerID:Int = 1) {
        this.playerID = playerID;
        reload();
    }

    public function reload() {
        var flush:Bool = false;
        for(prefs in default_list) {
            for(pref in prefs) {
                var saveDataSettingName:String = 'player${playerID}_SETTING_${pref.name}';
                var saveData:Dynamic = Reflect.getProperty(FlxG.save.data, saveDataSettingName);
                if(saveData != null) list[pref.name] = saveData;
                else {
                    flush = true;
                    list[pref.name] = pref.value;
                    Reflect.setProperty(FlxG.save.data, saveDataSettingName, pref.value);
                }
            }
        }
        // Load from defaultSaveData json file
        var items:Array<PrefData> = [];
        try {
            if(FileSystem.exists(Paths.json("data/defaultSaveData"))) {
                var json:Dynamic = Json.parse(Assets.load(TEXT, Paths.json("data/defaultSaveData")));
                items = json.items;
            }
        } catch(e) {
            Console.error(e.details());
        }

        for(pref in items) {
            var stupidAss:String = '${Paths.currentMod}:${pref.name}';
            var saveDataSettingName:String = 'player${playerID}_SETTING_$stupidAss';
            var saveData:Dynamic = Reflect.getProperty(FlxG.save.data, saveDataSettingName);
            if(saveData != null) list[stupidAss] = saveData;
            else {
                flush = true;
                list[stupidAss] = pref.value;
                Reflect.setProperty(FlxG.save.data, saveDataSettingName, pref.value);
            }
        }

        // Load note colors!!!
        for(key => value in Note.keyInfo) {
            var saveDataSettingName:String = 'player${playerID}_SETTING_NOTE_COLORS_$key';
            var saveData:Array<Array<Int>> = Reflect.getProperty(FlxG.save.data, saveDataSettingName);
            if(saveData != null) list['NOTE_COLORS_$key'] = saveData;
            else {
                flush = true;
                list['NOTE_COLORS_$key'] = value.colors;
                Reflect.setProperty(FlxG.save.data, saveDataSettingName, value.colors);
            }
        }

        if(flush) FlxG.save.flush();
    }

    public function get(name:String) {
        return list[name];
    }

    public function set(name:String, value:Dynamic) {
        list[name] = value;
    }

    public function flush() {
        for(name=>data in list) {
            var saveDataSettingName:String = 'player${playerID}_SETTING_$name';
            Reflect.setProperty(FlxG.save.data, saveDataSettingName, data);
        }
        FlxG.save.flush();
    }
}