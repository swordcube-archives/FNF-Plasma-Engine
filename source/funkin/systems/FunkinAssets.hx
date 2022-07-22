package funkin.systems;

#if MODS_ALLOWED
import softmod.SoftMod;
import sys.io.File;
#end

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import funkin.game.GlobalVariables;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

/**
    A class used for getting assets easier and better memory management for assets.
**/
class FunkinAssets
{
    /**
        The cache that stores all instances of `FlxGraphic`.
    **/
    public static var graphics:Map<String, FlxGraphic> = [];

    /**
        The cache that stores all instances of `Sound`.
    **/
    public static var sounds:Map<String, Sound> = [];

    /**
        Returns an image from `path`.
    **/
    public static function getImage(path:String):FlxGraphic
    {
        var graphic:FlxGraphic;

        if(!graphics.exists(path))
        {
            #if sys
            var bitmap = BitmapData.fromFile(path);
            var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
            texture.uploadFromBitmapData(bitmap);
            bitmap.dispose();
            bitmap.disposeImage();
            bitmap = null;

            graphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path, false);
            graphic.persist = true;
            #else
            graphic = FlxGraphic.fromAssetKey(path, false, path, false);
            graphic.persist = true;
            #end

            graphics.set(path, graphic);
        }

        return graphics.get(path);
    }

    /**
        Returns an sparrow atlas (FlxAtlasFrames) from `path`.
    **/
    public static function getSparrow(path:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(getImage(Paths.image(path)), getText(Paths.xml('images/$path')));
    }

    /**
        Returns an sparrow atlas (FlxAtlasFrames) from `char` for a character.
    **/
    public static function getCharacterSparrow(char:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(getImage('assets/characters/$char/spritesheet.png'), getText(Paths.xml('characters/$char/spritesheet')));
    }

    /**
        Returns the contents of a file from `path` as a `String`.

        @param path         The path
        @param mergeModded  Chooses whether or not to merge contents from the `assets` and `mods` folder. Off by default.
    **/
    public static function getText(path:String, ?mod:Null<String>, mergeModded:Bool = false):String
    {
        if(mergeModded)
        {
            var mergedString:String = "";

            if(Assets.exists(path))
                mergedString += Assets.getText(path);

            #if MODS_ALLOWED
            for(_mod in SoftMod.modsList)
            {
                if(SoftMod.modsList[GlobalVariables.selectedMod] == _mod)
                {
                    var path:String = '${Sys.getCwd()}${SoftMod.modsFolder}/$_mod/${path.split('assets/')[1]}';
                    if(sys.FileSystem.exists(path))
                    {
                        var fileContent = File.getContent(path);
                        if(fileContent.endsWith("\n"))
                            mergedString += fileContent;
                        else
                            mergedString += fileContent + "\n";
                    }
                }
            }
            #end

            return mergedString;
        }
        else
        {
            #if MODS_ALLOWED
            for(_mod in SoftMod.modsList)
            {
                if(SoftMod.modsList[GlobalVariables.selectedMod] == _mod)
                {
                    var path:String = '${Sys.getCwd()}${SoftMod.modsFolder}/$_mod/${path.split('assets/')[1]}';
                    if(sys.FileSystem.exists(path))
                        return File.getContent(path);
                }
            }
            #end

            if(Assets.exists(path))
                return Assets.getText(path);
        }
        
        return "";
    }

    /**
        Returns a sound from `path`.
    **/
    public static function getSound(path:String):Sound
    {
        if(!sounds.exists(path))
        {
            var dumbPath = path;
            
            #if MODS_ALLOWED
            for(_mod in SoftMod.modsList)
            {
                if(SoftMod.modsList[GlobalVariables.selectedMod] == _mod)
                {
                    var _path = '${Sys.getCwd()}${SoftMod.modsFolder}/$_mod/${path.split('assets/')[1]}';
                    if(sys.FileSystem.exists(_path))
                        dumbPath = _path;
                }
            }
            #end

            #if windows
            var goodPath = dumbPath.replace("/", "\\");
            #else
            var goodPath = dumbPath;
            #end

            #if sys
            sounds.set(path, Sound.fromFile(goodPath));
            #else
            @:privateAccess
            sounds.set(path, new FlxSound().loadEmbedded(goodPath)._sound);
            #end
        }

        return sounds.get(path);
    }

    /**
        Returns if `path` exists.
        @param path     The path
    **/
    public static function exists(path:String):Bool
    {
        #if MODS_ALLOWED
        for(_mod in SoftMod.modsList)
        {
            if(SoftMod.modsList[GlobalVariables.selectedMod] == _mod)
            {
                var path:String = '${Sys.getCwd()}${SoftMod.modsFolder}/$_mod/${path.split('assets/')[1]}';
                if(sys.FileSystem.exists(path))
                    return true;
            }
        }
        #end

        if(Assets.exists(path))
            return true;

        return false;
    }
}