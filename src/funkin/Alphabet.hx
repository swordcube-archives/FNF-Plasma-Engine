package funkin;

import flixel.math.FlxMath;
import base.BasicPoint;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

enum AlphabetFont {
    Bold;
    Default;
}

class Alphabet extends FlxTypedSpriteGroup<AlphabetChar> {
    public var font:AlphabetFont = Bold;
    public var size:Float = 1.0;
    public var text:String = "";

    public var isMenuItem:Bool = false;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

    public function new(x:Float, y:Float, font:AlphabetFont, text:String, size:Float = 1.0) {
        super(x, y);

        this.font = font;
        this.text = text;
        this.size = size;

        refreshText();
    }

    override function update(elapsed:Float) {
        if (isMenuItem) {
            var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

            var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
            y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
            if(forceX != Math.NEGATIVE_INFINITY)
                x = forceX;
            else
                x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
        }

        super.update(elapsed);
    }    

    public function refreshText() {
        for(a in members) {
            remove(a, true);
            a.destroy();
        }
        var splitChars:Array<String> = text.split("");
        var xPos:Float = 0.0;

        for(char in splitChars) {
            if(!AlphabetChar.supportedChars.contains(char)) continue;

            var alphaChar:AlphabetChar = new AlphabetChar(xPos, 0, font, char, size);
            add(alphaChar);

            if(char == " ") xPos += 30 * size;
            else xPos += alphaChar.width;
        }
    }
}

class AlphabetChar extends Sprite {
    public static var supportedChars:Array<String> = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()?,.<>“”'\\/ ".split("");

    public var char:String = "";
    public var font:AlphabetFont = Bold;
    public var size:Float = 1.0;

    public var useOutline:Bool = false;

    public function new(x:Float, y:Float, font:AlphabetFont, char:String, size:Float = 1.0) {
        super(x, y);

        this.font = font;
        this.char = char;
        loadFont();
    }

    override function draw() {
        if (font == Bold && !useOutline) {
            colorTransform.redMultiplier = color.redFloat;
            colorTransform.greenMultiplier = color.greenFloat;
            colorTransform.blueMultiplier = color.blueFloat;
            colorTransform.redOffset = 0;
            colorTransform.greenOffset = 0;
            colorTransform.blueOffset = 0;
        } else {
            colorTransform.redMultiplier = 0;
            colorTransform.greenMultiplier = 0;
            colorTransform.blueMultiplier = 0;
            colorTransform.redOffset = color.red;
            colorTransform.greenOffset = color.green;
            colorTransform.blueOffset = color.blue;
        }

        if (useOutline) {
            shader = new shaders.OutlineShader();
            var fr = frame.frame;
            cast(shader, shaders.OutlineShader).setClip(fr.x / pixels.width, fr.y / pixels.height, fr.width / pixels.width, fr.height / pixels.height);
            scale.set(size * 1.5, size * 1.5);
            updateHitbox();
            offset.add(offsets[animation.curAnim.name].x, offsets[animation.curAnim.name].y);
            offset.add(15, 10);
        } else {
            shader = null;
        }

        super.draw();
    }

    public function loadFont() {
        switch(font) {
            case Bold:
                load(SPARROW, Paths.image("ui/alphabet/bold"));
                var offsets:BasicPoint = {x: 0, y: 0};
                var anim:String = char.toUpperCase();
                switch(char.toUpperCase()) {
                    case " ":
                        visible = false;
                    case "😠", "😡":
                        anim = "-angry faic-";
                    case "'":
                        anim = "-apostraphie-";
                    case "\\":
                        anim = "-back slash-";
                    case "/":
                        anim = "-forward slash-";
                    case "“":
                        anim = "-start quote-";
                    case "”":
                        anim = "-end quote-";
                    case "?":
                        anim = "-question mark-";
                    case "!":
                        anim = "-exclamation point-";
                    case ".":
                        anim = "-period-";
                    case ",":
                        anim = "-comma-";
                    case "-":
                        anim = "-dash-";
                }
                addAnim("idle", anim+"0", 24, true, offsets);
                playAnim("idle");

                if(!animation.exists("idle")) {
                    this.font = Default;
                    useOutline = true;
                    x += 10 * size;
                    loadFont();
                }

                scale.set(size, size);
                updateHitbox();

            case Default:
                load(SPARROW, Paths.image("ui/alphabet/default"));
                var offsets:BasicPoint = {x: 0, y: 0};
                var anim:String = char;
                switch(char) {
                    case " ":
                        visible = false;
                    case "😠" | "😡":
                        anim = "-angry faic-";
                    case "'":
                        anim = "-apostraphie-";
                    case "\\":
                        anim = "-back slash-";
                    case "/":
                        anim = "-forward slash-";
                    case "“":
                        anim = "-start quote-";
                    case "”":
                        anim = "-end quote-";
                    case "?":
                        anim = "-question mark-";
                    case "!":
                        anim = "-exclamation point-";
                    case ".":
                        anim = "-period-";
                        offsets.y += 52 * size;
                    case ",":
                        anim = "-comma-";
                        offsets.y += 52 * size;
                    case "-":
                        anim = "-dash-";
                        offsets.y += 18 * size;

                    // letter offsets
                    case "a":
                        offsets.y += 15 * size;
                    case "b", "f":
                        offsets.y += 3 * size;
                    case "c":
                        offsets.y += 20 * size;
                    case "t", "h", "i", "j", "k", "l":
                        offsets.y += 5 * size;
                    case "e", "g":
                        offsets.y += 16 * size;
                    case "m", "n", "o", "p", "q", "r", "s", "u", "v", "w", "x", "y", "z":
                        offsets.y += 20 * size;

                    // Symbol Offsets
                    case ":", ";", "*":
                        offsets.y += 5 * size;
                }
                addAnim("idle", anim+"0", 24, true, offsets);
                playAnim("idle");

                scale.set(size, size);
                updateHitbox();

                offset.subtract(offsets.x, offsets.y);
        }
    }
}