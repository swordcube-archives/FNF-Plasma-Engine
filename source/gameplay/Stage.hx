package gameplay;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import hscript.HScript;
import states.PlayState;
import sys.FileSystem;

using StringTools;

class Stage extends FlxGroup
{
	// Default Stage
	public var bg:FlxSprite;
	public var stageFront:FlxSprite;
	public var stageCurtains:FlxSprite;

    // Foreground Sprites
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

        PlayState.current.dad = new Character(0, 0, PlayState.SONG.player2);
        PlayState.current.add(PlayState.current.dad);

        PlayState.current.gf = new Character(0, 0, PlayState.SONG.gf);
        PlayState.current.add(PlayState.current.gf);
        PlayState.current.add(inFrontOfGFSprites);

        PlayState.current.gf = new Character(0, 0, PlayState.SONG.player1);
        PlayState.current.add(PlayState.current.bf);
        PlayState.current.add(foregroundSprites);

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
				PlayState.defaultCamZoom = 0.9;

				bg = new FlxSprite(-600, -200);
				bg.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stageback')));
				bg.scrollFactor.set(0.9, 0.9);
                bg.antialiasing = Init.trueSettings.get("Antialiasing");
				add(bg);

				stageFront = new FlxSprite(-650, 600);
				stageFront.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stagefront')));
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.scale.set(1.1, 1.1);
				stageFront.updateHitbox();
                stageFront.antialiasing = Init.trueSettings.get("Antialiasing");
				add(stageFront);

				stageCurtains = new FlxSprite(-500, -300);
				stageCurtains.loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image('stages/stage/stagecurtains')));
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.scale.set(0.9, 0.9);
				stageCurtains.updateHitbox();
                stageCurtains.antialiasing = Init.trueSettings.get("Antialiasing");
				add(stageCurtains);

				// Run hscript and allow users to do Stage.removeDefaultStage();
				// To make their own custom stage
				if(FileSystem.exists(AssetPaths.hxs('stages/$curStage/script')))
				{
					trace("TRYING TO RUN SCRIPT! " + 'stages/$curStage/script.hxs');
					script = new HScript(AssetPaths.hxs('stages/$curStage/script'));
					script.setVariable("add", this.addSprite);
                    script.setVariable("remove", this.removeSprite);
                    script.setVariable("removeStage", this.removeDefaultStage);
                    script.setVariable("removeDefaultStage", this.removeDefaultStage);
					script.start();

					PlayState.current.scripts.push(script);
				}
				else
					trace('SCRIPT DOESN\'T EXIST IN STAGE DIRECTORY! (stages/$curStage/script.hxs)');
		}

        if(!repositionedCharacters)
        {
            repositionedCharacters = true;
            if(PlayState.current.dad != null)
            {
                PlayState.current.dad.x += dadPosition.x;
                PlayState.current.dad.y += dadPosition.y;
            }

            if(PlayState.current.gf != null)
            {
                PlayState.current.gf.x += gfPosition.x;
                PlayState.current.gf.y += gfPosition.y;
            }

            if(PlayState.current.bf != null)
            {
                PlayState.current.bf.x += gfPosition.x;
                PlayState.current.bf.y += gfPosition.y;
            }
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
            case "back":
                add(object);
            case "middle" | "gf":
                inFrontOfGFSprites.add(object);
            case "front":
                foregroundSprites.add(object);
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