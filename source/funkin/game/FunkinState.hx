package funkin.game;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxSound;
import funkin.systems.Conductor;
import funkin.systems.FunkinAssets;
import funkin.ui.FNFTransition;
import funkin.ui.GenesisFPS;
import openfl.system.System;

class FunkinState extends FlxUIState
{
    public var vanillaGameName:String = "Friday Night Funkin'";
    
    /**
        The replacement for `elapsed`. This is literally just `elapsed` but more accurate.
        Because by default `elapsed` can only go to like 0.023 or something dumb like that.
    **/
    public var delta:Float = 0.0;
    
    override public function create()
    {
        #if MODS_ALLOWED
        softmod.SoftMod.init({
            modsFolder: "mods",
            apiVersion: "0.1.0-a"
        });
        softmod.SoftMod.modsList.insert(0, vanillaGameName);
        #end
        
        super.create();

        if(!FlxTransitionableState.skipNextTransOut)
            openSubState(new FNFTransition(0.8, true));

        uncacheAll();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        FlxG.stage.frameRate = 1000;
        delta = 1 / GenesisFPS.currentFPS;
        
		var lastChange:BPMChange = {
			stepPosition: 0,
			position: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChanges.length)
		{
			if (Conductor.position >= Conductor.bpmChanges[i].position)
				lastChange = Conductor.bpmChanges[i];
		}

        var oldBeat:Int = Conductor.currentBeat;
        var oldStep:Int = Conductor.currentStep;

		Conductor.currentStepFloat = lastChange.stepPosition + ((Conductor.position - lastChange.position) / Conductor.stepCrochet);
        Conductor.currentBeatFloat = Conductor.currentStepFloat / 4;

		Conductor.currentStep = lastChange.stepPosition + Math.floor((Conductor.position - lastChange.position) / Conductor.stepCrochet);
        Conductor.currentBeat = Math.floor(Conductor.currentStep / 4);

        if(oldBeat != Conductor.currentBeat && Conductor.currentBeat > 0)
            beatHit();

        if(oldStep != Conductor.currentStep && Conductor.currentStep > 0)
            stepHit();
    }

    /**
        A function that executes every time a beat is hit.
        You're meant to override it.
    **/
    public function beatHit() {}
    /**
        A function that executes every time a step is hit.
        You're meant to override it.
    **/
    public function stepHit() {}

    /**
        A function to switch to a different state (with a fade transition!)

        @param newState        The state to actually switch to.
        @param skipTransition  Choose whether or not to instantly switch to `newState`.
    **/
    public function switchState(newState:FlxState, skipTransition:Bool = false)
    {
        FlxTransitionableState.skipNextTransOut = skipTransition;
        if (!skipTransition)
        {
            var curState:Dynamic = FlxG.state;
            curState.openSubState(new FNFTransition(0.8, false));
            FNFTransition.finishCallback = function()
            {
                FlxG.switchState(newState);
            };
            return;
        }
        FlxG.switchState(newState);
    }

    /**
        A function that gets rid of everything in the cache.
    **/
    public function uncacheAll()
    {
		FunkinAssets.graphics.clear();
        FunkinAssets.sounds.clear();

		FlxG.sound.list.forEachDead(function(sound:FlxSound)
		{
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.kill();
			sound.destroy();
		});

		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

        System.gc();
    }
}