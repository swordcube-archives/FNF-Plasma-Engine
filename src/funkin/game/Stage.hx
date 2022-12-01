package funkin.game;

import flixel.FlxBasic;
import flixel.group.FlxGroup;
import funkin.states.PlayState;
import flixel.math.FlxPoint;
import funkin.scripting.Script;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class Stage extends FlxGroup {
	public var script:ScriptModule;
	public var name:String = "default";

	public var dadLayer:StageLayer = new StageLayer();
	public var gfLayer:StageLayer = new StageLayer();
	public var bfLayer:StageLayer = new StageLayer();

	public var characterPositions:Map<String, FlxPoint> = [
        "dad" => new FlxPoint(100, 100),
        "gf"  => new FlxPoint(400, 130),
        "bf"  => new FlxPoint(770, 100)
    ];

	public function removePrevious() {
		if(script != null) {
			if(FlxG.state == PlayState.current)
				PlayState.current.scripts.removeScript(script);
			script.destroy();
		}
		for (i in [this, dadLayer, gfLayer, bfLayer]) {
			var a:Int = i.length;
			while (a > 0) {
				--a;
				var item = i.members[a];
				if (item != null) {
					item.kill();
					i.remove(item);
					item.destroy();
				}
			}
			i.clear();
		}
	}

	public function load(name:String = "default") {
		// Remove old members
		removePrevious();

        // Load stage
		switch(name) {
			default:
				script = Script.load(Paths.script('data/stages/$name'));
				if(FlxG.state == PlayState.current)
					script.setParent(PlayState.current);
				script.run(false);
				// Check if the script failed to load and load fallback if so
				// EmptyScript is the fallback type
				if(script.scriptType == EmptyScript) {
					if(FlxG.state == PlayState.current) {
						PlayState.current.scripts.removeScript(script);
						script.destroy();
						script = null;
					}
					removePrevious();
					loadFallback();
				} else {
					script.set("stage", this);
					script.set("add", function(obj:Dynamic, layer:Int = 0) {
						switch(layer) {
							case 0: this.add(obj);
							default:
								var layers:Array<StageLayer> = [dadLayer, gfLayer, bfLayer];
								layers[layer-1].add(obj);
						}
					});
					script.set("remove", function(obj:Dynamic) {
						for(i in [this, dadLayer, gfLayer, bfLayer]) {
							if(i.members.contains(obj)) {
								i.remove(obj);
								obj.kill();
								obj.destroy();
							}
						}
					});
					if(FlxG.state == PlayState.current)
						PlayState.current.scripts.addScript(script);
				}
				if(script != null) {
					script.createCall();
					// For if the script dies after create is ran
					if(script.scriptType == EmptyScript) {
						if(FlxG.state == PlayState.current) {
							PlayState.current.scripts.removeScript(script);
							script.destroy();
							script = null;
						}
						removePrevious();
						loadFallback();
					}
				}
		}

		return this;
	}

	function loadFallback() {
		Console.error("Stage couldn't load! Loading fallback...");

		var bg:BGSprite = new BGSprite(defaultStageImage('stageback'), -600, -200, 0.9, 0.9);
		add(bg);
	
		var stageFront:BGSprite = new BGSprite(defaultStageImage('stagefront'), -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);
	
		var stageLight:BGSprite = new BGSprite(defaultStageImage('stage_light'), -125, -100, 0.9, 0.9);
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.updateHitbox();
		add(stageLight);
	
		var stageLight:BGSprite = new BGSprite(defaultStageImage('stage_light'), 1225, -100, 0.9, 0.9);
		stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
		stageLight.updateHitbox();
		stageLight.flipX = true;
		add(stageLight);
	
		var stageCurtains:BGSprite = new BGSprite(defaultStageImage('stagecurtains'), -500, -300, 1.3, 1.3);
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		add(stageCurtains);
	}

	function defaultStageImage(asset:String) {
		return "stages/default/"+asset;
	}
}

class StageLayer extends FlxGroup {
	override public function add(obj:FlxBasic) {
		if (obj is FlxSprite && cast(obj, FlxSprite).antialiasing && !PlayerSettings.prefs.get("Antialiasing"))
			cast(obj, FlxSprite).antialiasing = false;
		return super.add(obj);
	}
}
