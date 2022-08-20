package ui;

import flixel.group.FlxGroup;
import hscript.HScript;

class JudgementUI extends FlxGroup
{
	public static var script:HScript;

	public function new()
	{
		super();
		
		if (script == null)
			script = new HScript("scripts/Judgement");
	}

	public function spawn_judgement(judgement:String, combo:Int, ratingScale:Float, comboScale:Float)
	{
		if (script != null)
		{
			// Set some variables
			script.set("ratingScale", ratingScale);
			script.set("comboScale", comboScale);

			script.set("this", this);
			script.set("add", this.add);
			script.set("remove", this.remove);
			script.set("kill", this.kill);
			script.set("destroy", this.destroy);

			// Start the script
			script.start(false); // Make the script function but don't automatically call the create function
			script.call("create", [judgement, combo]);
			script.call("createPost", [judgement, combo]);
			// because we call it down here
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		script.update(elapsed);
		script.call("updatePost", [elapsed]);
	}
	
	override public function destroy():Void
	{
		if (script != null)
			script.destroy();

		super.destroy();
	}
}
