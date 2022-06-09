package funkin.playState;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import hscript.HScript;
import lime.math.Vector2;
import states.PlayState;

class Stage extends FlxGroup
{
	// Default Stage
	public var bg:FlxSprite;
	public var stageFront:FlxSprite;
	public var stageCurtains:FlxSprite;

	// Foreground Sprite Group
	public var inFrontOfGFSprites:FlxGroup = new FlxGroup();
	public var foregroundSprites:FlxGroup = new FlxGroup();

	// Extra Variables
	public var curStage:String = "stage";
	public var script:HScript;

	// Character Positions, change on the "create()" function via
	// Stage.dadPosition.x = 0;
	// Stage.dadPosition.y = 0;
	// or somethin
	public var dadPosition:Vector2 = new Vector2(100, 100);
	public var gfPosition:Vector2 = new Vector2(400, 130);
	public var bfPosition:Vector2 = new Vector2(770, 100);

	// Functions
	public function new(stage:String)
	{
		super();
		changeStage(stage);
	}

	public function changeStage(stage:String)
	{
		// Remove previous stage
		for (m in members)
		{
			members.remove(m);
			m.kill();
			m.destroy();
		}

		for (m in inFrontOfGFSprites.members)
		{
			inFrontOfGFSprites.members.remove(m);
			m.kill();
			m.destroy();
		}

		for (m in foregroundSprites.members)
		{
			foregroundSprites.members.remove(m);
			m.kill();
			m.destroy();
		}

		// Set curStage to the value in the "stage" argument
		curStage = stage;

		// Spawn objects for current stage
		// The switch statement is here if you wanna hardcode
		// For whatever reason
		switch (curStage)
		{
			default:
				PlayState.instance.defaultCamZoom = 0.9;

				bg = new FlxSprite(-600, -200);
				bg.loadGraphic(GenesisAssets.getAsset('stages/stage/stageback', IMAGE));
				bg.scrollFactor.set(0.9, 0.9);
				add(bg);

				stageFront = new FlxSprite(-650, 600);
				stageFront.loadGraphic(GenesisAssets.getAsset('stages/stage/stagefront', IMAGE));
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.scale.set(1.1, 1.1);
				stageFront.updateHitbox();
				add(stageFront);

				stageCurtains = new FlxSprite(-500, -300);
				stageCurtains.loadGraphic(GenesisAssets.getAsset('stages/stage/stagecurtains', IMAGE));
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.scale.set(0.9, 0.9);
				stageCurtains.updateHitbox();
				add(stageCurtains);

				// Run hscript and allow users to do Stage.removeDefaultStage();
				// To make their own custom stage
				if (GenesisAssets.exists('images/stages/$curStage/script.hx', HSCRIPT))
				{
					trace("TRYING TO RUN SCRIPT! " + 'images/stages/$curStage/script.hx');
					script = new HScript('images/stages/$curStage/script.hx');
					script.interp.variables.set("Stage", this);
					script.state = PlayState.instance;
					script.start();

					PlayState.instance.scripts.push(script);
				}
				else
					trace('SCRIPT DON\'T EXIST IN STAGE DIRECTORY! (images/stages/$curStage/script.hx)');
		}
	}

	public function addSprite(object:FlxBasic, layer:String = "BACK")
	{
		switch (layer.toLowerCase())
		{
			case "back":
				add(object);
			case "gf" | "middle":
				inFrontOfGFSprites.add(object);
			case "front":
				foregroundSprites.add(object);
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
}
