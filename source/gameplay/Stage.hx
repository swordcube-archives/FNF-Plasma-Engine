package gameplay;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import hscript.HScript;
import states.PlayState;
import sys.FileSystem;
import systems.Conductor;

using StringTools;

class Stage extends FlxGroup {
    // Information
    public var curStage:String = "stage";
    public var script:HScript;

    // Character Positions
	public var dadPosition:FlxPoint = new FlxPoint(100, 100);
	public var gfPosition:FlxPoint = new FlxPoint(400, 130);
	public var bfPosition:FlxPoint = new FlxPoint(770, 100);

    public function new(stage:String = "stage")
    {
        super();

        loadStage(stage);
    }

    public function loadStage(stage:String)
    {        
		// Remove previous stage
		for (m in members)
		{
			remove(m, true);
			m.kill();
			m.destroy();
		}

		// Set curStage to the value in the "stage" argument
		curStage = stage;

		// Spawn objects for current stage
		// The switch statement is here if you wanna hardcode
		// For whatever reason
		switch(curStage) {
			default:
                var path:String = AssetPaths.hxs('stages/$curStage');
                for(ext in HScript.hscriptExts) {
                    if(FileSystem.exists(AssetPaths.asset('stages/$curStage'+ext)))
                        path = AssetPaths.asset('stages/$curStage'+ext);
                }
                
				if(FileSystem.exists(path)) {
                    #if DEBUG_PRINTING
					Main.print('debug', 'Trying to run "stages/$curStage"');
                    #end
				} else {
					#if DEBUG_PRINTING
					Main.print('debug', 'Could not run "stages/$curStage", loading default instead...');
					#end
					curStage = 'stage';
				}
				script = new HScript('stages/$curStage');
				script.set("stage", this);
				script.set("add", this.add);
				script.set("insert", this.insert);
				script.set("remove", this.remove);
				script.set("members", this.members);
				script.start();
		}
    }
}