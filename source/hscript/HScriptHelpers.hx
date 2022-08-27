package hscript;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import openfl.media.Sound;
import flixel.text.FlxText;
import openfl.display.BlendMode;
import flixel.FlxCamera.FlxCameraFollowStyle;

class HScriptHelpers {
    // i didn't know you could do this whole
    //
    // set("Something" {
    //     "someVariableOrFunctionInThisBracketShit": function(balls:String) {
    //         return someActualFunctionThatHScriptHatesButCanBeDoneHere(balls);
    //     },
    //     "beans": FlxColor.BROWN
    // });
    //
    // thing, but uh
    // https://github.com/YoshiCrafter29/hscript-improved/blob/master/script/RunScript.hx
    // line 74 is where i found this information

    /**
        Returns ALMOST the entire FlxColor class.
        I have to add each color and function here manually, and there is a bit much to add.
        So i'm only adding the important stuff, If you want to add more yourself, go nuts.
    **/
    public static function getFlxColor()
    {
        return {
            // color lore
            "BLACK": FlxColor.BLACK,
            "BLUE": FlxColor.BLUE,
            "BROWN": FlxColor.BROWN,
            "CYAN": FlxColor.CYAN,
            "GRAY": FlxColor.GRAY,
            "GREEN": FlxColor.GREEN,
            "LIME": FlxColor.LIME,
            "MAGENTA": FlxColor.MAGENTA,
            "ORANGE": FlxColor.ORANGE,
            "PINK": FlxColor.PINK,
            "PURPLE": FlxColor.PURPLE,
            "RED": FlxColor.RED,
            "TRANSPARENT": FlxColor.TRANSPARENT,
            "WHITE": FlxColor.WHITE,
            "YELLOW": FlxColor.YELLOW,

            // functions
            "add": FlxColor.add,
            "fromCMYK": FlxColor.fromCMYK,
            "fromHSB": FlxColor.fromHSB,
            "fromHSL": FlxColor.fromHSL,
            "fromInt": FlxColor.fromInt,
            "fromRGB": FlxColor.fromRGB,
            "fromRGBFloat": FlxColor.fromRGBFloat,
            "fromString": FlxColor.fromString,
            "interpolate": FlxColor.interpolate,
        };
    }

    public static function getFNFAssets()
    {
        return {
            "getImage": function(path:String):FlxGraphic {
                return FNFAssets.returnAsset(IMAGE, path);
            },
            "getSparrow": function(path:String):FlxAtlasFrames {
                return FNFAssets.returnAsset(SPARROW, path);
            },
            "getCharacterSparrow": function(path:String):FlxAtlasFrames {
                return FNFAssets.returnAsset(CHARACTER_SPARROW, path);
            },
            "getPacker": function(path:String):FlxAtlasFrames {
                return FNFAssets.returnAsset(PACKER, path);
            },
            "getCharacterPacker": function(path:String):FlxAtlasFrames {
                return FNFAssets.returnAsset(CHARACTER_PACKER, path);
            },
            "getStoryCharacterSparrow": function(path:String):FlxAtlasFrames {
                return FNFAssets.returnAsset(CHARACTER_SPARROW, path);
            },
            "getSound": function(path:String):Sound {
                return FNFAssets.returnAsset(SOUND, path);
            },
            "getText": function(path:String):String {
                return FNFAssets.returnAsset(TEXT, path);
            }
        };
    }

    public static function getBlendMode()
    {
        return {
            "ADD": BlendMode.ADD,
            "ALPHA": BlendMode.ALPHA,
            "DARKEN": BlendMode.DARKEN,
            "DIFFERENCE": BlendMode.DIFFERENCE,
            "ERASE": BlendMode.ERASE,
            "HARDLIGHT": BlendMode.HARDLIGHT,
            "INVERT": BlendMode.INVERT,
            "LAYER": BlendMode.LAYER,
            "LIGHTEN": BlendMode.LIGHTEN,
            "MULTIPLY": BlendMode.MULTIPLY,
            "NORMAL": BlendMode.NORMAL,
            "OVERLAY": BlendMode.OVERLAY,
            "SCREEN": BlendMode.SCREEN,
            "SHADER": BlendMode.SHADER,
            "SUBTRACT": BlendMode.SUBTRACT
        };
    }

    public static function getFlxCameraFollowStyle()
    {
        return {
            "LOCKON": FlxCameraFollowStyle.LOCKON,
            "PLATFORMER": FlxCameraFollowStyle.PLATFORMER,
            "TOPDOWN": FlxCameraFollowStyle.TOPDOWN,
            "TOPDOWN_TIGHT": FlxCameraFollowStyle.TOPDOWN_TIGHT,
            "SCREEN_BY_SCREEN": FlxCameraFollowStyle.SCREEN_BY_SCREEN,
            "NO_DEAD_ZONE": FlxCameraFollowStyle.NO_DEAD_ZONE
        };
    }
    
    public static function getFlxTextAlign()
    {
        return {
            "LEFT": "left",
            "CENTER": "center",
            "RIGHT": "right",
            "JUSTIFY": "justify",
            "fromOpenFL": FlxTextAlign.fromOpenFL,
            "toOpenFL": FlxTextAlign.toOpenFL
        };
    }
    
    public static function getFlxTextBorderStyle()
    {
        return {
            "NONE": FlxTextBorderStyle.NONE,
            "SHADOW": FlxTextBorderStyle.SHADOW,
            "OUTLINE": FlxTextBorderStyle.OUTLINE,
            "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
        };
    }

    /*
        you can use
        "var Thing = importScript('scripts/balls');"
        or some shit for using this
    */
    public static function importScript(source)
    {
        var the = {};
        var balls = new HScript(StringTools.replace(source, '.', '/'));
        for (i in Reflect.fields(balls.getAll())) {
            Reflect.setField(the, i, balls.get(i));
        }
        try{
            return the;
        } catch(e) {
            Main.print("error", "Could not get fields of the script " + source);
            return null;
        }
    }
}