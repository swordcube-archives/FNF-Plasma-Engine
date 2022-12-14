// Does not work in macros
#if !macro
import base.Paths;
import funkin.system.CoolUtil;
import funkin.system.MathUtil;
import flixel.FlxG;
#if discord_rpc
import base.DiscordRPC;
#end
import funkin.system.Song;
import funkin.system.Section;
import base.Console;
import funkin.system.Conductor;
import base.Highscore;
import base.Assets;
import flixel.util.FlxColor;
import funkin.system.PlayerSettings;
#end

// Works in macros
import sys.io.File;
import sys.FileSystem;
import tjson.TJSON as Json;
import openfl.utils.Assets as OpenFLAssets;
import lime.utils.Assets as LimeAssets;