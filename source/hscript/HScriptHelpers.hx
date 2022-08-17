package hscript;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import openfl.media.Sound;

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
    public static function getFlxColorClass()
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

    public static function getFNFAssetsClass()
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
            "getSound": function(path:String):Sound {
                return FNFAssets.returnAsset(SOUND, path);
            },
            "getText": function(path:String):String {
                return FNFAssets.returnAsset(TEXT, path);
            }
        };
    }
}