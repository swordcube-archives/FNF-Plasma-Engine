package states;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import systems.MusicBeat;

using StringTools;

class PreloadState extends MusicBeatState
{
    var assetCount:Int = 0;
    
	var images = [];
	var sounds = [];

    var loadingText:FlxText;

    override function create()
    {
        super.create();
        
        Main.fpsCounter.visible = false;

        var logo:FlxSprite = new FlxSprite().loadGraphic("assets/engineLogo.png");
        logo.scale.set(0.3, 0.3);
        logo.updateHitbox();
        logo.screenCenter();
        add(logo);

        loadingText = new FlxText(0, logo.y + 250, 0, "Loading Assets...", 24);
        loadingText.setFormat(AssetPaths.font("vcr"), 24, FlxColor.WHITE);
        loadingText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        loadingText.screenCenter(X);
        add(loadingText);

        // Preload Characters
        var charFolder = '${AssetPaths.cwd}assets/${AssetPaths.currentPack}/characters';
        if(FileSystem.exists(charFolder))
        {
            for(fucker in FileSystem.readDirectory(charFolder))
            {
                if(!fucker.contains(".")) // basically a check to see if the folder is a folder
                {
                    var dumbassPath:String = charFolder+"/"+fucker;
                    for(item in FileSystem.readDirectory(dumbassPath))
                    {
                        if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                        {
                            assetCount++;
                            images.push(dumbassPath+"/"+item);
                        }
                    }
                }
            }
        }

        // Preload Songs
        var songsFolder = '${AssetPaths.cwd}assets/${AssetPaths.currentPack}/songs';
        if(FileSystem.exists(songsFolder))
        {
            for(fucker in FileSystem.readDirectory(songsFolder))
            {
                if(!fucker.contains(".")) // basically a check to see if the folder is a folder
                {
                    var dumbassPath:String = songsFolder+"/"+fucker;
                    for(item in FileSystem.readDirectory(dumbassPath))
                    {
                        // This is the songs folder so why try to load any images lmao
                        if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                        {
                            assetCount++;
                            sounds.push(dumbassPath+"/"+item);
                        }
                    }
                }
            }
        }

        // Images
        addToCacheList("images");
        addToCacheList("images/icons");
        addToCacheList("images/countdown");
        addToCacheList("images/mainmenu");
        addToCacheList("images/arrows");
        addToCacheList("images/splashes");
        addToCacheList("images/title");
        addToCacheList("images/stages/stage");

        // Music & Sounds
        addToCacheList("music");
        addToCacheList("sounds");
        addToCacheList("sounds/menus");

		sys.thread.Thread.create(() -> {
			cache();
		});
    }

    /**
        Adds the contents of `folder` to the cache list so the contents can be cached.
        
        @param folder       The folder to preload assets from.
    **/
    function addToCacheList(folder:String)
    {
        var dumbassPath:String = '${AssetPaths.cwd}assets/${AssetPaths.currentPack}/$folder';
        
        if(!dumbassPath.contains(".") && FileSystem.exists(dumbassPath))
        {
            for(item in FileSystem.readDirectory(dumbassPath))
            {
                if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                {
                    assetCount++;
                    images.push(dumbassPath+"/"+item);
                }
                else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                {
                    assetCount++;
                    sounds.push(dumbassPath+"/"+item);
                }
            }
        }
    }

    var loadedSoFar:Int = 0;

    function cache()
    {
        for(i in images)
        {
            loadedSoFar++;
			var data:BitmapData = BitmapData.fromFile(i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			FNFAssets.permCache.set(i+":IMAGE", graph);
            trace("LOADED IMAGE "+i);
        }

		for (i in sounds)
		{
            loadedSoFar++;
            FNFAssets.permCache.set(i+":SOUND", Sound.fromFile(i));
			trace("LOADED SOUND "+i);
		}

        Main.fpsCounter.visible = true;
        Main.switchState(new states.TitleState(), false);
    }

    var textUpdateTimer:Float = 0.0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        loadingText.text = "Loaded "+loadedSoFar+"/"+assetCount+" assets";
        loadingText.screenCenter(X);
    }
}
