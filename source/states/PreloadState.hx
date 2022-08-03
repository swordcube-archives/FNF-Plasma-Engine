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

        addToCacheList(""); // preload any images that may happen to be in root assets folderr
        addToCacheList("images");
        addToCacheList("images/icons");
        addToCacheList("images/mainmenu");
        addToCacheList("images/arrows");
        addToCacheList("images/splashes");
        addToCacheList("images/stages");
        addToCacheList("images/title");

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
        // Don't load contents from this place if it isn't a folder or if it doesn't exist!!!
        if(dumbassPath.contains(".") || !FileSystem.exists(dumbassPath)) return;

        for(item in FileSystem.readDirectory(dumbassPath))
        {
            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                images.push(dumbassPath+"/"+item);
            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                sounds.push(dumbassPath+"/"+item);
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
            loadingText.text = "Loaded "+loadedSoFar+"/"+images.length+sounds.length+" assets";
            loadingText.screenCenter(X);
            trace("LOADED IMAGE "+i);
        }

		for (i in sounds)
		{
            loadedSoFar++;
            FNFAssets.permCache.set(i+":SOUND", Sound.fromFile(i));
            loadingText.text = "Loaded "+loadedSoFar+"/"+images.length+sounds.length+" assets";
            loadingText.screenCenter(X);
			trace("LOADED SOUND "+i);
		}

        Main.fpsCounter.visible = true;
        Main.switchState(new states.TitleState(), false);
    }
}
