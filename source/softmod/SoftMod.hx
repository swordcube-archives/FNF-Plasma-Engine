package softmod;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ModInfo = {
    var modsFolder:String;
    var apiVersion:String;
};

typedef ModJSON = {
    var modName:String;
    var modDesc:String;
    var apiVersion:String;
}

/**
    A custom class for managing mods.
**/
class SoftMod
{
    static public var modsFolder:String = "";
    static public var apiVersion:String = "0.1.0-a";

    /**
        A list of all mods.
    **/
    static public var modsList:Array<String> = [];

    /**
        A function for initializing SoftMod.

        `info` is a variable containing `ModInfo` with contents such as:

        ________________________________________________________________________________

        `modsFolder`     The folder to use for all mods.

        `apiVersion`     A version number you can change to force older mods to not load.
    **/
    static public function init(info:ModInfo)
    {
        modsFolder = info.modsFolder;
        apiVersion = info.apiVersion;

        modsList = [];

        var scannedModsFolder:Array<String> = FileSystem.readDirectory('${Sys.getCwd()}$modsFolder');
        for(thing in scannedModsFolder)
        {
            if(!thing.contains(".")) // if the thing is a folder then add it to the mods list
                modsList.push(thing);
        }

        for(folder in modsList)
        {
            var path:String = '${Sys.getCwd()}$modsFolder/$folder/softmod_info.json';
            if(FileSystem.exists(path))
            {
                var content:ModJSON = haxe.Json.parse(File.getContent(path));
                if(content.apiVersion != apiVersion)
                {
                    modsList.remove(folder);
                    trace('$folder is outdated! $folder won\'t be loaded.');
                }
                else
                    trace('$folder was successfully loaded!');
            }
            else
            {
                modsList.remove(folder);
                trace('$folder doesn\'t have "softmod_info.json"! $folder won\'t be loaded.');
            }
        }
    }
}
#end