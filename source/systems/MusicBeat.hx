package systems;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUISubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import hscript.Global;
import openfl.system.System;
import systems.Conductor;
import ui.Notification;

class MusicBeatState extends FlxUIState {
	// original variables extended from original game source
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var allowF5:Bool = true;

	public var camNotif:FlxCamera;

	public var notificationGroup:FlxTypedGroup<Notification>;

	override function create()
	{
		Global.reset();
		Init.initializeSettings();

		Init.arrowSkins = Init.getArrowSkins();
		
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new Transition(0.45, true));

		FlxG.sound.list.forEachAlive(function(sound:FlxSound)
		{ // clears sounds from memory
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.kill();
			sound.destroy();
		});

        // clears all bitmaps from memory
		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		// clear all cache
		FNFAssets.clearCache();

        // run the garbage collector
        System.gc();

		super.create();

		FlxG.cameras.reset();
		camNotif = new FlxCamera();
		camNotif.bgColor = 0x0;

		FlxG.cameras.add(camNotif, false);

		notificationGroup = new FlxTypedGroup<Notification>();
		notificationGroup.cameras = [camNotif];
		add(notificationGroup);
    }

	override function update(elapsed:Float)
	{
		FlxG.autoPause = Settings.get("Auto Pause");

		if(FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		var dumb:Int = 0;
		if (notificationGroup != null) {
			notificationGroup.forEachAlive(function(notif:Notification) {
				notif.scrollFactor.set();
				notif.y = 20 + ((notif.box.height + 20) * dumb);
				if(notif.shouldDie)
				{
					notificationGroup.remove(notif, true);
					notif.kill();
					notif.destroy();
				}
	
				dumb++;
			});
		}
		updateContents();

		// state refreshing
		if(FlxG.keys.justPressed.F5)
			if (allowF5)
				resetState();

		super.update(elapsed);
	}

	function resetState()
		Main.resetState();

	public function updateContents()
	{
		updateCurStep();
		updateBeat();

		// delta time bullshit
		var trueStep:Int = Conductor.currentStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				Conductor.currentStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
		{
			// trace('skipped steps $skippedSteps');
			skippedSteps = [];
		}
		Conductor.currentStep = trueStep;

		//
		if (oldStep != Conductor.currentStep && Conductor.currentStep > 0 && !storedSteps.contains(Conductor.currentStep))
			stepHit();
		oldStep = Conductor.currentStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateBeat():Void
	{
		Conductor.currentBeat = Math.floor(Conductor.currentStep / 4);
		Conductor.currentBeatFloat = Conductor.currentStepFloat / 4;
	}

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.position >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		Conductor.currentStep = lastChange.stepTime + Math.floor((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
		Conductor.currentStepFloat = lastChange.stepTime + ((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (!storedSteps.contains(Conductor.currentStep))
			storedSteps.push(Conductor.currentStep);
		else
		{
			trace('SOMETHING WENT WRONG??? STEP REPEATED ${Conductor.currentStep}');
			return;
		}

		if (Conductor.currentStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// used for updates when beats are hit in classes that extend this one
	}
}

class MusicBeatSubState extends FlxUISubState {
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	override function update(elapsed:Float)
	{
		updateContents();

		super.update(elapsed);
	}

	public function updateContents()
	{
		updateCurStep();
		updateBeat();

		// delta time bullshit
		var trueStep:Int = Conductor.currentStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				Conductor.currentStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
		{
			// trace('skipped steps $skippedSteps');
			skippedSteps = [];
		}
		Conductor.currentStep = trueStep;

		//
		if (oldStep != Conductor.currentStep && Conductor.currentStep > 0 && !storedSteps.contains(Conductor.currentStep))
			stepHit();
		oldStep = Conductor.currentStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateBeat():Void
	{
		Conductor.currentBeat = Math.floor(Conductor.currentStep / 4);
		Conductor.currentBeatFloat = Conductor.currentStepFloat / 4;
	}

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.position >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		Conductor.currentStep = lastChange.stepTime + Math.floor((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
		Conductor.currentStepFloat = lastChange.stepTime + ((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (!storedSteps.contains(Conductor.currentStep))
			storedSteps.push(Conductor.currentStep);
		else
		{
			trace('SOMETHING WENT WRONG??? STEP REPEATED ${Conductor.currentStep}');
			return;
		}

		if (Conductor.currentStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// used for updates when beats are hit in classes that extend this one
	}
}