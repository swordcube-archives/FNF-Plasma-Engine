package engine;

import flixel.addons.ui.FlxUISubState;
import scenes.PlayState;

// I like calling substates subscenes shut the fuck up
class Subscene extends FlxUISubState {
    public var allowF5Refreshing:Bool = true;

    // Doing this stupidness so i can forget to do super.blablabla and not worry about that
    override function create() {
        super.create();
        start();
    }

    // Override these!
    public function start() {}

    public function process(elapsed:Float) {}

    public function beatHit(curBeat:Int) {}
    public function stepHit(curStep:Int) {}

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(FlxG.state == PlayState.current) {
			if(allowF5Refreshing && FlxG.keys.justPressed.F5) {
				PlayState.current = null;
				Main.resetScene();
			}
		} else {
			if(allowF5Refreshing && FlxG.keys.justPressed.F5)
				Main.resetScene();
		}
        Conductor.update(elapsed);
        process(elapsed);
    }
}