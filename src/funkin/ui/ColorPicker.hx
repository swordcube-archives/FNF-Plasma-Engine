package funkin.ui;

import openfl.desktop.ClipboardTransferMode;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import flixel.group.FlxSpriteGroup;
import openfl.geom.ColorTransform;
import funkin.shaders.ColorShader;
import openfl.geom.Matrix;
import flixel.util.FlxGradient;
import funkin.system.BitmapHelper;
import openfl.display.BitmapData;
import flixel.ui.FlxButton;
import funkin.system.FNFSprite;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

/**
 * A color picker with resetting, copying, and pasting.
 * 
 * @author RafGamign (Original Code made in Plasma 0.1.2 HScript) (https://github.com/swordcube/FNF-Plasma-Engine/blob/main/assets/funkin/objects/sprites/ui/ColorPicker.hxs)
 * @author swordcube (Converting to hardcoded Haxe)
 */
class ColorPicker extends FlxSpriteGroup {
    var size:FlxPoint = FlxPoint.get(0,0);

    var fullGradient:BitmapData;
    var hueChooser:BitmapData;

    var curColor = 0xFFFF0000;

    var hue:Float = 0;
    var sat:Float = 0;
    var bri:Float = 100;

    var gradientSprite:FNFSprite;
    var hueSprite:FlxSprite;
    var hueSlider:FNFSprite;
    var sbSlider:FNFSprite;

    var copyButton:FlxButton;
    var pasteButton:FlxButton;
    var resetButton:FlxButton;

    var slidingHue = false;
    var slidingSB = false;

    public var onChange:(Float, Float, Float)->Void = null;
    public var onReset:Void->Void = null;

    /**
     * Creates a new `ColorPicker` instance.
     * @param x The X position
     * @param y The Y position
     * @param w The width of the color picker
     * @param h The height of the color picker
     */
    public function new(x:Float, y:Float, w:Int, h:Int, onResetShit:Void->Void) {
        super(x, y);

        onReset = onResetShit;

        size.set(w, h);

        hueChooser = new BitmapData(360, 20, true, 0);
        fullGradient = new BitmapData(w, h, true, 0);
        hueSprite = new FlxSprite(0,h);
        var singleStripe = FlxGradient.createGradientBitmapData(Std.int(size.x), 1, [0xFFFFFFFF, 0xFFFF0000], 1, 0);
        for (i in 0...Std.int(size.y)) {
            fullGradient.draw(
                singleStripe,
                new Matrix(
                    1, 0, 0,
                    1, 0, i
                ),
                new ColorTransform(
                    1-i/(size.y-20),1-i/(size.y-20),1-i/(size.y-20)
                )
            );
        }
        for (i in 0...360) {
            var coolPixel = new BitmapData(1, 1, false, FlxColor.fromHSB(i,1,1));
            hueChooser.draw(
                coolPixel,
                new Matrix(
                    1, 0, 0,
                    20, i, 0
                )
            );
        }
        hueSprite.loadGraphic(hueChooser);
        hueSprite.setGraphicSize(w, 20);
        hueSprite.updateHitbox();
        gradientSprite = new FNFSprite();
        gradientSprite.loadGraphic(fullGradient);
        gradientSprite.shader = new ColorShader(255,0,0);
    
        hueSlider = new FNFSprite(-10,h+1);
        hueSlider.loadGraphic(BitmapHelper.newOutlinedCircle(8, 0x27FFFFFF, 2, 0x7FFFFFFF));
        sbSlider = new FNFSprite(-10,-10);
        sbSlider.loadGraphic(BitmapHelper.newOutlinedCircle(8, 0x27FFFFFF, 2, 0x7FFFFFFF));

        copyButton = new FlxButton(w+10, 10, "Copy", function() {
            var clipboardText = Clipboard.generalClipboard.setData(TEXT_FORMAT, '#'+StringTools.hex(curColor-0xFF000000, 6));
        });

        pasteButton = new FlxButton(w+10, 44, "Paste", function() {
            var clipboardText = Clipboard.generalClipboard.getData(TEXT_FORMAT, CLONE_PREFERRED);
            if (clipboardText != null) {
                var parsedColor:Null<FlxColor> = FlxColor.fromString(clipboardText);
                trace(parsedColor);
                if (parsedColor != null) {
                    setColor(parsedColor, true);
                    onChange(hue,sat/100,bri/100);
                }
            }
        });

        resetButton = new FlxButton(w+10, 78, "Reset", onReset);

        add(hueSprite);
        add(gradientSprite);
        add(hueSlider);
        add(sbSlider);

        add(copyButton);
        add(pasteButton);
        add(resetButton);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(hueSprite)) {
            slidingHue = true;
        } else if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(gradientSprite)) {
            slidingSB = true;
        }
        if (FlxG.mouse.justReleased) {
            slidingHue = false;
            slidingSB = false;
        }
    
        if (slidingHue) {
            hue = (FlxG.mouse.x-x)/size.x*360;
            updateHue();
            if (onChange != null)
                onChange(hue,sat/100,bri/100);
        } else if (slidingSB) {
            sat = (FlxG.mouse.x-x)/size.x*100;
            bri = (100-((FlxG.mouse.y-y)/size.y*100))+(y - 20);
            updateSB();
            if (onChange != null)
                onChange(hue,sat/100,bri/100);
        }
    
        if (slidingHue || slidingSB) {
            curColor = FlxColor.fromHSB(hue, sat/100, bri/100);
        }
    }

    public function setColor(color:Dynamic, isInt:Bool) {
        var fRGB:Dynamic = color;
        if (isInt)
            fRGB = getRGB(color);
        hue = get_hue(fRGB.r, fRGB.g, fRGB.b);
        sat = (maxOf3(fRGB.r,fRGB.g,fRGB.b) - minOf3(fRGB.r,fRGB.g,fRGB.b)) / maxOf3(fRGB.r,fRGB.g,fRGB.b)*100;
        bri = maxOf3(fRGB.r, fRGB.g, fRGB.b)/255*100;
        updateHue();
        updateSB();
        curColor = FlxColor.fromHSB(hue, sat/100, bri/100);
    }
    
    function updateHue() {
        if (hue < 0) hue = 0;
        if (hue > 360) hue = 360;
        hueSlider.x = x + hue/360*size.x-9;
        var thecolor = FlxColor.fromHSB(hue,1,1);
        cast(gradientSprite.shader, ColorShader).setColors(
            (thecolor >> 16) & 0xff,
            (thecolor >> 8) & 0xff,
            thecolor & 0xff
        );
    }
    
    function updateSB() {
        if (sat < 0) sat = 0;
        if (sat > 100) sat = 100;
        if (bri < 0) bri = 0;
        if (bri > 100) bri = 100;
    
        sbSlider.x = x + sat/100*size.x-9;
        sbSlider.y = size.y + (y - bri/100*size.y-9);
    }
    
    function getRGB(hex) {
        return {
            'r': (hex >> 16) & 0xff,
            'g': (hex >> 8) & 0xff,
            'b': hex & 0xff
        };
    }
    function getFloatRGB(hex) {
        return {
            'r': ((hex >> 16) & 0xff) /255,
            'g': ((hex >> 8) & 0xff) /255,
            'b': (hex & 0xff) /255
        };
    }
    
    function maxOf3(a,b,c) { return Math.max(a, Math.max(b, c)); }
    function minOf3(a,b,c) { return Math.min(a, Math.min(b, c)); }
    
    function get_hue(redFloat, greenFloat, blueFloat) {
        var hueRad = Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
        var thehue:Float = 0;
        if (hueRad != 0)
            thehue = 180 / Math.PI * Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
    
        return thehue < 0 ? thehue + 360 : thehue;
    }
}