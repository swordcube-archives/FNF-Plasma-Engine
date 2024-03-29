package gameplay;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import hscript.HScript;
import states.PlayState;
import sys.FileSystem;

using StringTools;

class Stage extends FlxGroup {
	// Default Stage
	public var bg:FlxSprite;
	public var stageFront:FlxSprite;
	public var stageCurtains:FlxSprite;

    // Foreground Sprites
	public var inFrontOfDadSprites:FlxGroup = new FlxGroup();
    public var inFrontOfGFSprites:FlxGroup = new FlxGroup();
    public var foregroundSprites:FlxGroup = new FlxGroup();

    // Character Positions
	public var dadPosition:FlxPoint = new FlxPoint(100, 100);
	public var gfPosition:FlxPoint = new FlxPoint(400, 130);
	public var bfPosition:FlxPoint = new FlxPoint(770, 100);

    // Misc
    public var curStage:String = "stage";
    public var script:HScript;

    public var repositionedCharacters:Bool = false;

    public function new(stage:String = "stage")
    {
        super();

        loadStage(stage);
    }

    public function loadStage(stage:String)
    {
        if(script != null)
            PlayState.current.scripts.remove(script);
        
		// Remove previous stage
		for (m in members)
		{
			remove(m, true);
			m.kill();
			m.destroy();
		}

		for (m in inFrontOfDadSprites.members)
		{
			inFrontOfDadSprites.remove(m, true);
			m.kill();
			m.destroy();
		}

		for (m in inFrontOfGFSprites.members)
		{
			inFrontOfGFSprites.remove(m, true);
			m.kill();
			m.destroy();
		}

		for (m in foregroundSprites.members)
		{
			foregroundSprites.remove(m, true);
			m.kill();
			m.destroy();
		}

		// Set curStage to the value in the "stage" argument
		curStage = stage;

		// Spawn objects for current stage
		// The switch statement is here if you wanna hardcode
		// For whatever reason
		switch(curStage)
		{
			default:
				PlayState.current.defaultCamZoom = 0.9;

				bg = new FlxSprite(-600, -200);
				bg.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stageback')));
				bg.scrollFactor.set(0.9, 0.9);
                bg.antialiasing = Settings.get("Antialiasing");
				add(bg);

				stageFront = new FlxSprite(-650, 600);
				stageFront.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stagefront')));
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.scale.set(1.1, 1.1);
				stageFront.updateHitbox();
                stageFront.antialiasing = Settings.get("Antialiasing");
				add(stageFront);

				stageCurtains = new FlxSprite(-500, -300);
				stageCurtains.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stagecurtains')));
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.scale.set(0.9, 0.9);
				stageCurtains.updateHitbox();
                stageCurtains.antialiasing = Settings.get("Antialiasing");
				add(stageCurtains);

				// Run hscript and allow users to do removeDefaultStage();
				// To make their own custom stage
                var path:String = AssetPaths.hxs('stages/$curStage');
                for(ext in HScript.hscriptExts)
                {
                    if(FileSystem.exists(AssetPaths.asset('stages/$curStage'+ext)))
                        path = AssetPaths.asset('stages/$curStage'+ext);
                }
                
				if(FileSystem.exists(path))
				{
					#if DEBUG_PRINTING
					Main.print('debug', 'Trying to run "stages/$curStage"');
					#end
					script = new HScript('stages/$curStage');
                    if(PlayState.current != null)
                        script.setScriptObject(PlayState.current);
                    script.set("stage", this);
					script.set("add", this.addSprite);
                    script.set("remove", this.removeSprite);
                    script.set("removeStage", this.removeDefaultStage);
                    script.set("removeDefaultStage", this.removeDefaultStage);
					script.start();

                    if(PlayState.current != null)
					    PlayState.current.scripts.push(script);
				}
				#if DEBUG_PRINTING
				else
					Main.print('debug', 'Could not run "stages/$curStage"');
				#end
		}
    }

	public function removeDefaultStage()
	{
		remove(bg);
		remove(stageFront);
		remove(stageCurtains);
		bg.kill();
		stageFront.kill();
		stageCurtains.destroy();
	}

    public function addSprite(object:FlxBasic, layer:String = "back")
    {
        switch(layer.toLowerCase())
        {
            case "middle" | "gf":
                inFrontOfGFSprites.add(object);
            case "bf" | "front":
                foregroundSprites.add(object);
            default:
                add(object);
        }
    }

    public function removeSprite(object:FlxBasic, ?destroy:Bool = false)
    {
        for(member in members)
        {
            if(member == object)
            {
                remove(member, destroy);
                if(destroy)
                {
                    member.kill();
                    member.destroy();
                }
                break;
            }
        }

        for(member in inFrontOfGFSprites.members)
        {
            if(member == object)
            {
                inFrontOfGFSprites.remove(member, destroy);
                if(destroy)
                {
                    member.kill();
                    member.destroy();
                }
                break;
            }
        }

        for(member in foregroundSprites.members)
        {
            if(member == object)
            {
                foregroundSprites.remove(member, destroy);
                if(destroy)
                {
                    member.kill();
                    member.destroy();
                }
                break;
            }
        }
    }
}