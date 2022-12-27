package funkin.game;

import funkin.scripting.Script;
import funkin.system.FNFSprite;

/**
 * An `FlxSprite` that has a script attached to it.
 */
class ScriptedSprite extends FNFSprite {
    public var script:ScriptModule;

    /**
     * Initializes the sprite and script.
     * @param script The path to the script.
     */
    public function new(x:Float, y:Float, script:String, ?args:Array<Dynamic>) {
        super(x, y);

        this.script = Script.load(Paths.script('data/scripts/sprites/$script'));
        this.script.setParent(this);

        if(args == null) args = [];
        this.script.run(true, args);
        this.script.createPostCall(args);
    }

    /**
     * Updates the script and sprite.
     * @param elapsed The time between frames.
     */
    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        if(!exists) return;
        super.update(elapsed);
        script.updatePostCall(elapsed);
	}

    /**
     * A function that gets called when the sprite is destroyed.
     */
    override public function destroy() {
        script.call("onDestroy");
        script.call("destroy");
        script.destroy();
        super.destroy();
    }

    /**
     * A function that gets called when the sprite is killed.
     */
     override public function kill() {
        script.call("onKill");
        script.call("kill");
        super.kill();
    }

    /**
     * A function that gets called when the sprite is revived.
     */
     override public function revive() {
        script.call("onRevive");
        script.call("revive");
        super.revive();
    }
}