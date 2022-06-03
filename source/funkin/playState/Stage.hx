package funkin.playState;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import states.PlayState;

@:enum abstract StageLayer(String) to String
{
	var BACK = 'back';
	var ABOVE_GF = 'above_gf';
	var FRONT = 'front';
}

class Stage extends FlxGroup
{
    // Default Stage
    public var bg:FlxSprite;
    public var stageFront:FlxSprite;
    public var stageCurtains:FlxSprite;

    // Foreground Sprite Group
    public var foregroundSprites:FlxGroup = new FlxGroup();

    // Extra Variables
    public var curStage:String = "stage";

    // Functions
    public function new(stage:String)
    {
        super();
        changeStage(stage);
    }

    public function changeStage(stage:String)
    {
        // Remove previous stage
        for(m in members)
        {
            members.remove(m);
            m.kill();
            m.destroy();
        }

        for(m in foregroundSprites.members)
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
        switch(curStage)
        {
            default:
                PlayState.instance.defaultCamZoom = 0.9;
                
                bg = new FlxSprite(-600, -200);
                bg.loadGraphic(GenesisAssets.getAsset('stages/$curStage/stageback', IMAGE));
                bg.scrollFactor.set(0.9, 0.9);
                add(bg);

                stageFront = new FlxSprite(-650, 600);
                stageFront.loadGraphic(GenesisAssets.getAsset('stages/$curStage/stagefront', IMAGE));
                stageFront.scrollFactor.set(0.9, 0.9);
                stageFront.scale.set(1.1, 1.1);
                stageFront.updateHitbox();
                add(stageFront);

                stageFront = new FlxSprite(-500, -300);
                stageFront.loadGraphic(GenesisAssets.getAsset('stages/$curStage/stagecurtains', IMAGE));
                stageFront.scrollFactor.set(1.3, 1.3);
                stageFront.scale.set(0.9, 0.9);
                stageFront.updateHitbox();
                add(stageFront);

                // Run hscript and allow users to do Stage.removeDefaultStage();
                // To make their own custom stage
        }
    }
}