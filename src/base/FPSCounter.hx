package base;

import external.memory.Memory;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
 */
class FPSCounter extends TextField {
	//                                      fps   mem   version
	public var infoDisplayed:Array<Bool> = [true, true, true];
	public var currentFPS:Int = 0;

	var fpsCounter:FPS;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0xFFFFFF, ?font:String)
	{
		super();

		x = inX;
		y = inY;
		selectable = false;

		var font = Paths.font('vcr.ttf'); // default font is usually _sans, but vcr looks nicer
		defaultTextFormat = new TextFormat(font, 14, inCol);

		fpsCounter = new FPS(-10000, -10000, inCol);
		fpsCounter.visible = false;
		Lib.current.addChild(fpsCounter);

		addEventListener(Event.ENTER_FRAME, onEnter);
		width = FlxG.width;
		height = FlxG.height;
	}

	private function onEnter(event:Event) {
		currentFPS = fpsCounter.currentFPS;
		infoDisplayed = [Settings.get('FPS Counter'), Settings.get('Memory Counter'), Settings.get('Display Version')];

		if (visible) {
			text = "";
			for (i in 0...infoDisplayed.length) {
				if (infoDisplayed[i]) {
					switch (i) {
						case 0:
							fpsFunction();
						#if cpp
						case 1:
							memoryFunction();
						#end
						case 2:
							versionFunction();
					}

					text += "\n";
				}
			}
		}
		else
			text = "";
	}

	function fpsFunction() {
    	text += currentFPS+' FPS';
	}
	#if cpp
	function memoryFunction() {
        text += CoolUtil.getSizeLabel(Memory.getCurrentUsage())+" / "+CoolUtil.getSizeLabel(Memory.getPeakUsage());
	}
	#end
	function versionFunction() {
		text += 'v'+Main.engineVersion;
	}
}
