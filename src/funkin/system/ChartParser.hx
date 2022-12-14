package funkin.system;

using StringTools;

@:enum abstract ChartType(String) from String to String {
    var VANILLA = "VANILLA"; // For regular FNF charts
    var PSYCH = "PSYCH";
    var BASE = "BASE"; // For charts with the new format
    var AUTO = "AUTO"; // Automatically guess the chart type
}

class ChartParser {
    public inline static function loadFromText(text:String):Song {
        return cast Json.parse(text).song;
    }
    public static function loadSong(type:ChartType, name:String, diff:String = "normal"):Song {
        switch(type) {
            // Guess the chart type
            case AUTO:
                if(FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff'))) {
                    var chart:Dynamic = Json.parse(Assets.load(TEXT, Paths.json('songs/${name.toLowerCase()}/$diff'))).song;
                    if(chart.sections != null && chart.scrollSpeed != null) {
                        // Guessed "BASE"!
                        return loadSong(BASE, name, diff);
                    }
                    var assNuts:Array<Dynamic> = chart.notes;
                    if(assNuts != null) {
                        for(section in assNuts) {
                            if(section.sectionBeats != null) {
                                // Guessed "PSYCH"!
                                return loadSong(PSYCH, name, diff);
                            }
                        }
                    }
                    // If we can't guess anything else, just guess "VANILLA"!
                    return loadSong(VANILLA, name, diff);
                }

            // Convert vanilla FNF chart to new format
            case VANILLA:
                if(FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff'))) {
                    var vanillaChart:LegacySong = cast Json.parse(Assets.load(TEXT, Paths.json('songs/${name.toLowerCase()}/$diff'))).song;
                    if(vanillaChart.stage == null || vanillaChart.stage == "stage") vanillaChart.stage = "default";

                    var sections:Array<Section> = [];
                    for(section in vanillaChart.notes) {
                        if(section != null) {
                            var coolSex:Section = {
                                notes: [],
                                playerSection: section.mustHitSection,
                                altAnim: section.altAnim,
                                bpm: section.bpm,
                                changeBPM: section.changeBPM,
                                lengthInSteps: section.lengthInSteps
                            }
                            for(note in section.sectionNotes) {
                                var altAnim:Bool = section.altAnim;
                                if(note[3] != null && note[3]) altAnim = note[3];

                                coolSex.notes.push({
                                    strumTime: note[0],
                                    direction: Std.int(note[1]),
                                    sustainLength: note[2],
                                    altAnim: altAnim,
                                    type: "Default"
                                });
                            }
                            sections.push(coolSex);
                        }
                    }
                    var keyAmount:Int = 4;
                    var gfVersion:String = "gf";
                    if(vanillaChart.player3 != null) gfVersion = vanillaChart.player3;
                    if(vanillaChart.gfVersion != null) gfVersion = vanillaChart.gfVersion;
                    if(vanillaChart.gf != null) gfVersion = vanillaChart.gf;
                    if(vanillaChart.keyCount != null) keyAmount = vanillaChart.keyCount;
                    if(vanillaChart.keyNumber != null) keyAmount = vanillaChart.keyNumber;
                    if(vanillaChart.mania != null) {
                        switch(vanillaChart.mania) {
                            case 1: keyAmount = 6;
                            case 2: keyAmount = 7;
                            case 3: keyAmount = 9;
                            default: keyAmount = 4;
                        }
                    }
                    return {
                        name: vanillaChart.song,
                        bpm: vanillaChart.bpm,
                        scrollSpeed: vanillaChart.speed,
                        sections: sections,
                        events: [],
                        needsVoices: vanillaChart.needsVoices,

                        keyAmount: keyAmount,
            
                        dad: vanillaChart.player2,
                        bf: vanillaChart.player1,
                        gf: gfVersion, // Ik base game charts don't have this but i am not hardcoding gfVersion
                        stage: vanillaChart.stage
                    };
                }
            
            // Only supports 0.6+ charts because i think charts older than that can just use the VANILLA type
            case PSYCH:
                if(FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff'))) {
                    var psychChart:PsychSong = cast Json.parse(Assets.load(TEXT, Paths.json('songs/${name.toLowerCase()}/$diff'))).song;
                    if(psychChart.stage == null || psychChart.stage == "stage") psychChart.stage = "default";

                    var eventList:Array<EventGroup> = [];
                    var sections:Array<Section> = [];
                    for(section in psychChart.notes) {
                        if(section != null) {
                            var secBeats:Float = section.sectionBeats != null ? section.sectionBeats : 4.0;
                            var coolSex:Section = {
                                notes: [],
                                playerSection: section.mustHitSection,
                                altAnim: section.altAnim,
                                bpm: section.bpm,
                                changeBPM: section.changeBPM,
                                lengthInSteps: Std.int(secBeats * 4) // section beats is a float!!! what the fuck!!!
                            }
                            for(note in section.sectionNotes) {
                                var altAnim:Bool = section.altAnim;
                                if(note[3] != null && ((note[3] is Bool && note[3]) || (note[3] is String && note[3] == "Alt Animation")))
                                    altAnim = true;

                                coolSex.notes.push({
                                    strumTime: note[0],
                                    direction: Std.int(note[1]),
                                    sustainLength: note[2],
                                    altAnim: altAnim,
                                    type: note[3] is String ? note[3] : "Default"
                                });
                            }
                            sections.push(coolSex);
                        }
                    }
                    var gfVersion:String = "gf";
                    if(psychChart.player3 != null) gfVersion = psychChart.player3;
                    if(psychChart.gfVersion != null) gfVersion = psychChart.gfVersion;
                    for(event in psychChart.events) {
                        var convertedEventGroup:EventGroup = {
                            strumTime: event[0],
                            events: []
                        };
                        for (i in 0...event[1].length) {
                            var eventData:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
                            switch(eventData[1]) {
                                case "Screen Shake":
                                    // Lazy fix
                                    var shit1:Array<String> = eventData[2].split(",");
                                    var shit2:Array<String> = eventData[3].split(",");
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["game", shit1[0].trim(), shit1[1].trim()]
                                    });
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["hud", shit2[0].trim(), shit2[1].trim()]
                                    });

                                case "Change Scroll Speed":
                                    // Lazy fix (again)
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["opponent", eventData[2], eventData[3]]
                                    });
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["player", eventData[2], eventData[3]]
                                    });

                                case "Change Character":
                                    // because in psych 0 = bf and 1 = dad
                                    // even though the charter says otherwise
                                    if(eventData[2] == "0")
                                        eventData[2] = "1";
                                    else if(eventData[2] == "1")
                                        eventData[2] = "0";
                                    
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: [eventData[2], eventData[3]]
                                    });

                                default:
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: [eventData[2], eventData[3]]
                                    });
                            }
                        }
                        eventList.push(convertedEventGroup);
                    }
                    return {
                        name: psychChart.song,
                        bpm: psychChart.bpm,
                        scrollSpeed: psychChart.speed,
                        sections: sections,
                        events: eventList,
                        needsVoices: psychChart.needsVoices,

                        keyAmount: 4,
            
                        dad: psychChart.player2,
                        bf: psychChart.player1,
                        gf: gfVersion,
                        stage: psychChart.stage
                    };
                }

            default: 
                if(FileSystem.exists(Paths.json('songs/${name.toLowerCase()}/$diff')))
                    return cast Json.parse(Assets.load(TEXT, Paths.json('songs/${name.toLowerCase()}/$diff'))).song;
        }
        // Default return for if the JSON couldn't be found
        return {
            name: "Test",
            bpm: 150,
            scrollSpeed: 1.0,
            sections: [],
            events: [],
            needsVoices: true,

            keyAmount: 4,

            dad: "dad",
            bf: "bf",
            gf: "gf",
            stage: "default"
        };
    }
}