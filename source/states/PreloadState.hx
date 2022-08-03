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

        // Preload All Characters
        var initialFolder:String = 'characters';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Some Images
        var initialFolder:String = 'images';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Some Main Menu Images
        var initialFolder:String = 'mainmenu';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Some Notes
        var initialFolder:String = 'arrows';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Some Splashes
        var initialFolder:String = 'splashes';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Some Stage Images
        var initialFolder:String = 'stages/stage';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload All Icons
        var initialFolder:String = 'images/icons';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload Almost All Sounds
        var initialFolder:String = 'sounds';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

        // Preload All Menu Sounds
        var initialFolder:String = 'sounds/menus';
        for(piss in FileSystem.readDirectory('${AssetPaths.cwd}assets/'))
        {
            if(!piss.contains(".") && FileSystem.exists('${AssetPaths.cwd}assets/$piss/$initialFolder'))
            {
                for(folder in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder'))
                {
                    if(!folder.contains("."))
                    {
                        for(item in FileSystem.readDirectory('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder'))
                        {
                            if(item.endsWith(".png") || item.endsWith(".jpg") || item.endsWith(".bmp"))
                                images.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                            else if(item.endsWith(".mp3") || item.endsWith(".ogg") || item.endsWith(".wav"))
                                sounds.push('${AssetPaths.cwd}assets/$piss/$initialFolder/$folder/$item');
                        }
                    }
                }
            }
        }

		sys.thread.Thread.create(() -> {
			cache();
		});
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
