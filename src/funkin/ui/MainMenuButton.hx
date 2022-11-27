package funkin.ui;

import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.system.FNFSprite;

class MainMenuButton extends FNFSprite {
    public var name:String = "";

    public var flickerBG:Bool = true;
    public var onAccept:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

    public function new(x:Float, y:Float, name:String) {
        super(x, y);
        this.name = name;

        load(SPARROW, Paths.image('menus/main/${name}'));
        addAnim("idle", "basic", 24, true);
        addAnim("select", "white", 24, true);
        playAnim("idle");
    }

    override function playAnim(anim:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		super.playAnim(anim, force, reversed, frame);

        centerOrigin();
        offset.copyFrom(origin);
    }
}