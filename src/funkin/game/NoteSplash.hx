package funkin.game;

import funkin.shaders.ColorShader;
import flixel.math.FlxPoint;
import funkin.game.Note.NoteSplashSkin;
import funkin.system.FNFSprite;

class NoteSplash extends FNFSprite {
    public var splashOffsets:FlxPoint = new FlxPoint();
    public var skinJSON:NoteSplashSkin;
    public var splashScale:Float = 0.7;

    public var colorShader = new ColorShader(255, 0, 0);

    public function new(x:Float = 0, y:Float = 0, rgb:Array<Int>, keyAmount:Int = 4, direction:String = "left", skin:String = "Default") {
        super(x, y);

        skinJSON = Note.splashSkinJSONs[skin];
        if(skinJSON == null) skinJSON = Note.splashSkinJSONs["Default"];
        load(SPARROW, Paths.image(skinJSON.texturePath));

        addAnim("splash1", direction+" splash 1", skinJSON.frameRate);
        addAnim("splash2", direction+" splash 2", skinJSON.frameRate);

        var randAnim:Int = FlxG.random.int(1, 2);

        switch(randAnim) {
            case 1: splashOffsets.set(skinJSON.offsets[0], skinJSON.offsets[1]);
            case 2: splashOffsets.set(skinJSON.offsets2[0], skinJSON.offsets2[1]);
        }

        splashScale = skinJSON.scale * Note.keyInfo[keyAmount].scale;
        scale.set(splashScale, splashScale);
        updateHitbox();
        playAnim("splash"+randAnim);

        animation.finishCallback = function(name:String) {
            kill();
            destroy();
        }

        alpha = skinJSON.alpha;
        colorShader.setColors(rgb[0], rgb[1], rgb[2]);
        if(skinJSON.noteColorsAllowed) shader = colorShader;
    }

    override public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
        super.playAnim(name, force, reversed, frame);

        centerOrigin();
        offset.x = frameWidth / 2;
        offset.y = frameHeight / 2;

        offset.x -= 156 * (splashScale / 2);
        offset.y -= 156 * (splashScale / 2);

        offset.subtract(splashOffsets.x, splashOffsets.y);
    }
}