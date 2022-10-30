package funkin;

import funkin.states.PlayState;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import scripting.Script;
import scripting.ScriptModule;
import scripting.HScriptModule;
import flixel.group.FlxGroup;

class Stage extends FlxGroup {
    public var curStage:String = "";
    public var script:ScriptModule;

    public var layeredGroups:Array<FlxGroup> = [
        new FlxGroup(), // above dad
        new FlxGroup(), // above gf
        new FlxGroup()  // above bf
    ];

    public var characterPositions:Map<String, FlxPoint> = [
        "dad" => new FlxPoint(100, 100),
        "gf"  => new FlxPoint(400, 130),
        "bf"  => new FlxPoint(770, 100)
    ];

    /**
     * Loads a new stage and removes the currently loaded one.
     * @param name The stage to load.
     * @param mod The mod to load from.
     */
    public function loadStage(name:String, ?mod:Null<String>) {
        curStage = name;
        if(script != null) PlayState.current.scripts.removeScript(script);
        for(fuck in [this, layeredGroups[0], layeredGroups[1], layeredGroups[2]]) {
            fuck.forEach(function(a) {
                fuck.remove(a, true);
                a.destroy();
            });
        }
        // It's recommended to use an .hxs file in "assets/data/stages" but you can
        // hardcode if you want too
        switch(name) {
            default:
                script = Script.create(Paths.hxs('data/stages/$name', mod));
                // Check if the script is a generic one (shouldn't happen unless file doesn't exist)
                if(Std.isOfType(script, ScriptModule)) {
                    script.destroy();
                    script = Script.create(Paths.hxs('data/stages/default', mod));
                }
                if(Std.isOfType(script, HScriptModule)) {
                    script.set("mod", mod);
                    cast(script, HScriptModule).setScriptObject(PlayState.current);
                }
                script.set("add", function(obj:FlxBasic, layer:Int = 0) {
                    switch(layer) {
                        case 0: add(obj);
                        default: layeredGroups[layer-1].add(obj);
                    }
                });
                script.set("remove", function(obj:FlxBasic) {
                    for(fuck in [this, layeredGroups[0], layeredGroups[1], layeredGroups[2]]) {
                        fuck.forEach(function(a) {
                            if(a != obj) return;
                            fuck.remove(a, true);
                            a.destroy();
                        });
                    }
                });
                script.set("stage", this);
                script.start(true, []);
                PlayState.current.scripts.addScript(script);
        }
        return this;
    }
}