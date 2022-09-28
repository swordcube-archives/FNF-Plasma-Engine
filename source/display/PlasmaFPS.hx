package display;

import flixel.FlxG;
import lime.app.Application;
import openfl.Lib;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
 */
class PlasmaFPS extends TextField {
	//                                      fps   mem   version
	public var infoDisplayed:Array<Bool> = [true, true, true];

	public var memPeak:Int = 0;
	public var currentFPS:Int = 0;

	var fpsCounter:FPS;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0xFFFFFF, ?font:String)
	{
		super();

		x = inX;
		y = inY;
		selectable = false;

		var font = AssetPaths.font('vcr', TTF); // default font is usually _sans, but vcr looks nicer
		defaultTextFormat = new TextFormat(font, 14, inCol);

		fpsCounter = new FPS(10000, 10000, inCol);
		fpsCounter.visible = false;
		Lib.current.addChild(fpsCounter);

		addEventListener(Event.ENTER_FRAME, onEnter);
		width = FlxG.width;
		height = FlxG.height;
	}

	private function onEnter(event:Event)
	{
		currentFPS = fpsCounter.currentFPS;
		Main.deltaTime = currentFPS > 240 ? 1.0 / currentFPS : FlxG.elapsed;

		infoDisplayed = [true, true, true];

		if (visible)
		{
			text = "";

			for (i in 0...infoDisplayed.length)
			{
				if (infoDisplayed[i])
				{
					switch (i)
					{
						case 0:
							// FPS
                            if (Init.trueSettings.get('Show FPS'))
							fps_Function();
						case 1:
							// Memory
                            if (Init.trueSettings.get('Show Memory'))
							memory_Function();
						case 2:
							// Version
                            if (Init.trueSettings.get('Show Version'))
							version_Function();
					}

					text += "\n";
				}
			}
		}
		else
			text = "";
	}

	function fps_Function()
	{
        if (!Init.trueSettings.get('Simplify Info'))
		text += "FPS: " + currentFPS;
        else
        text += currentFPS + 'fps';
	}

	function memory_Function()
	{
		if (System.totalMemory > memPeak)
			memPeak = System.totalMemory;

        if (!Init.trueSettings.get('Simplify Info'))
		text += "MEM: " + Main.getSizeLabel(System.totalMemory) + " / " + Main.getSizeLabel(memPeak);
        else
        text += Main.getSizeLabel(System.totalMemory);
	}

	function version_Function()
	{
        if (!Init.trueSettings.get('Simplify Info'))
		text += "Version: " + Application.current.meta.get('version');
        else
		text += 'v'+Application.current.meta.get('version');
	}
}
