package funkin.scripting.hscript;

import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import flixel.FlxCamera.FlxCameraFollowStyle;
import openfl.display.BlendMode;
import flixel.input.keyboard.FlxKey;

/**
 * A big sloppy mess of functions and/or variables for `HScriptModule`.
 * 
 * When i say sloppy, ***i mean sloppy***
 */
class HScriptUtil {
    public static function getDefaultImports():Map<String, Dynamic> {
        return [
            // Variables
            "mod" => Paths.currentMod, // Shortcut to `Paths.currentMod`

            // Abstracts
            "FlxColor" => {
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
                "to24Bit": function(color:Int) {
                    return color & 0xffffff;
                },
            },
            "FlxKey" => {
                'ANY': -2,
                'NONE': -1,
                'A': 65,
                'B': 66,
                'C': 67,
                'D': 68,
                'E': 69,
                'F': 70,
                'G': 71,
                'H': 72,
                'I': 73,
                'J': 74,
                'K': 75,
                'L': 76,
                'M': 77,
                'N': 78,
                'O': 79,
                'P': 80,
                'Q': 81,
                'R': 82,
                'S': 83,
                'T': 84,
                'U': 85,
                'V': 86,
                'W': 87,
                'X': 88,
                'Y': 89,
                'Z': 90,
                'ZERO': 48,
                'ONE': 49,
                'TWO': 50,
                'THREE': 51,
                'FOUR': 52,
                'FIVE': 53,
                'SIX': 54,
                'SEVEN': 55,
                'EIGHT': 56,
                'NINE': 57,
                'PAGEUP': 33,
                'PAGEDOWN': 34,
                'HOME': 36,
                'END': 35,
                'INSERT': 45,
                'ESCAPE': 27,
                'MINUS': 189,
                'PLUS': 187,
                'DELETE': 46,
                'BACKSPACE': 8,
                'LBRACKET': 219,
                'RBRACKET': 221,
                'BACKSLASH': 220,
                'CAPSLOCK': 20,
                'SEMICOLON': 186,
                'QUOTE': 222,
                'ENTER': 13,
                'SHIFT': 16,
                'COMMA': 188,
                'PERIOD': 190,
                'SLASH': 191,
                'GRAVEACCENT': 192,
                'CONTROL': 17,
                'ALT': 18,
                'SPACE': 32,
                'UP': 38,
                'DOWN': 40,
                'LEFT': 37,
                'RIGHT': 39,
                'TAB': 9,
                'PRINTSCREEN': 301,
                'F1': 112,
                'F2': 113,
                'F3': 114,
                'F4': 115,
                'F5': 116,
                'F6': 117,
                'F7': 118,
                'F8': 119,
                'F9': 120,
                'F10': 121,
                'F11': 122,
                'F12': 123,
                'NUMPADZERO': 96,
                'NUMPADONE': 97,
                'NUMPADTWO': 98,
                'NUMPADTHREE': 99,
                'NUMPADFOUR': 100,
                'NUMPADFIVE': 101,
                'NUMPADSIX': 102,
                'NUMPADSEVEN': 103,
                'NUMPADEIGHT': 104,
                'NUMPADNINE': 105,
                'NUMPADMINUS': 109,
                'NUMPADPLUS': 107,
                'NUMPADPERIOD': 110,
                'NUMPADMULTIPLY': 106,
    
                'fromStringMap': FlxKey.fromStringMap,
                'toStringMap': FlxKey.toStringMap,
                'fromString': FlxKey.fromString,
                'toString': function(key:Int) {
                    return FlxKey.toStringMap.get(key);
                },
            },
            "BlendMode" => {
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
            },
            "FlxCameraFollowStyle" => {
                "LOCKON": FlxCameraFollowStyle.LOCKON,
                "PLATFORMER": FlxCameraFollowStyle.PLATFORMER,
                "TOPDOWN": FlxCameraFollowStyle.TOPDOWN,
                "TOPDOWN_TIGHT": FlxCameraFollowStyle.TOPDOWN_TIGHT,
                "SCREEN_BY_SCREEN": FlxCameraFollowStyle.SCREEN_BY_SCREEN,
                "NO_DEAD_ZONE": FlxCameraFollowStyle.NO_DEAD_ZONE
            },
            "FlxTextAlign" => {
                "LEFT": FlxTextAlign.LEFT,
                "CENTER": FlxTextAlign.CENTER,
                "RIGHT": FlxTextAlign.RIGHT,
                "JUSTIFY": FlxTextAlign.JUSTIFY,
                "fromOpenFL": FlxTextAlign.fromOpenFL,
                "toOpenFL": FlxTextAlign.toOpenFL
            },
            "FlxTextBorderStyle" => {
                "NONE": FlxTextBorderStyle.NONE,
                "SHADOW": FlxTextBorderStyle.SHADOW,
                "OUTLINE": FlxTextBorderStyle.OUTLINE,
                "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
            },

            // Classes (Haxe)
            "Json" => {
                "parse": function(data:String) {return Json.parse(data);},
                "stringify": function(data:Dynamic, thing:String = "\t") {return Json.encode(data, thing == "\t" ? "fancy" : null);}
            },
            "Array" => Array,
            "Float" => Float,
            "Int" => Int,
            "Bool" => Bool,
            "Dynamic" => Dynamic,
            "Type" => Type,
            "Reflect" => Reflect,
            "Main" => Main,
            "Std" => Std,
            "Math" => Math,
            "String" => String,
            "StringTools" => StringTools,
            "Date" => Date,
            "DateTools" => DateTools,

            // Classes (Flixel)
            "FlxG" => flixel.FlxG,
            "FlxSprite" => flixel.FlxSprite,
            "FlxText" => flixel.text.FlxText,
            "FlxMath" => flixel.math.FlxMath,
            "FlxTimer" => flixel.util.FlxTimer,
            "FlxTween" => flixel.tweens.FlxTween, 
            "FlxEase" => flixel.tweens.FlxEase,

            // FlxAxes is also a goofy ass abstract!!!!!!!!!!
            "FlxAxes" => {
                "X": flixel.util.FlxAxes.X,
                "Y": flixel.util.FlxAxes.Y,
                "XY": flixel.util.FlxAxes.XY,
                "YX": flixel.util.FlxAxes.XY,
                "NONE": flixel.util.FlxAxes.NONE,
                "fromString": function(str:String) {
                    return switch(str.toLowerCase()) {
                        case "x": flixel.util.FlxAxes.X;
                        case "y": flixel.util.FlxAxes.Y;
                        case "xy", "yx", "both": flixel.util.FlxAxes.XY;
                        case "none", "", null: flixel.util.FlxAxes.NONE;
                        default: flixel.util.FlxAxes.NONE;
                    }
                },
                "fromBools": function(x:Bool, y:Bool) {
                    return cast(x ? (cast X : Int) : 0) | (y ? (cast Y : Int) : 0);
                }
            },
            "FlxGroup" => flixel.group.FlxGroup,

            // FlxPoint is a goofy ass abstract now!!
            @:access(flixel.math.FlxPoint.FlxBasePoint)
            "FlxPoint" => flixel.math.FlxPoint.FlxBasePoint,
            
            // Classes (Funkin)
            "Paths" => Paths,
            "Assets" => Assets,
            "FNFSprite" => funkin.system.FNFSprite,
            "CoolUtil" => CoolUtil,
            "MathUtil" => MathUtil,
            "PlayerSettings" => PlayerSettings,
            "Script" => funkin.scripting.Script,
            "VideoHelper" => funkin.system.VideoHelper,
            "Conductor" => Conductor,
            "StrumLine" => funkin.game.StrumLine,
            "Receptor" => funkin.game.StrumLine.Receptor,
            "Note" => funkin.game.Note,
            "CustomShader" => funkin.shaders.CustomShader,
            "ScriptedSprite" => funkin.game.ScriptedSprite,
            "ScriptableState" => funkin.states.ScriptableState,
            "ScriptableSubState" => funkin.substates.ScriptableSubState,
            "prefs" => PlayerSettings.prefs,
            "controls" => PlayerSettings.controls,
            "PlayState" => funkin.states.PlayState.current,
            "PlayState_" => funkin.states.PlayState,
            "global" => (funkin.states.PlayState.current != null ? funkin.states.PlayState.current.global : cast([], Map<String, Dynamic>))
        ];
    }
}