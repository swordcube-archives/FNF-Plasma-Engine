package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import gameplay.Note;
import gameplay.StrumLine;
import gameplay.StrumNote;
import openfl.media.Sound;
import systems.MusicBeat;
import systems.UIControls;

class KeybindMenu extends MusicBeatSubState
{
    var scrollMenu:Sound;
    var confirmMenu:Sound;

    var bindToChange:Int = 0;
    var isChangingBind:Bool = false;
    
    var bg:FlxSprite;
    var strumLine:StrumLine;

    var warnText:FlxText;

    var textGroup:FlxTypedGroup<FlxText>;

    public function new(keyCount:Int, showBG:Bool)
    {
        super();

        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        scrollMenu = FNFAssets.returnAsset(SOUND, AssetPaths.sound("menus/scrollMenu"));
        confirmMenu = FNFAssets.returnAsset(SOUND, AssetPaths.sound("menus/confirmMenu"));

        if(showBG)
        {
            bg = new FlxSprite().loadGraphic(FNFAssets.returnAsset(IMAGE, AssetPaths.image("menuBGDesat")));
            bg.color = 0xFFea71fd;
            bg.scrollFactor.set();
            add(bg);
        }
        else
        {
            bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
            bg.alpha = 0.6;
            bg.scrollFactor.set();
            add(bg); 
        }
        
        strumLine = new StrumLine(0, (FlxG.height/2)-(Note.swagWidth/2), keyCount);
        strumLine.scrollFactor.set();
        strumLine.screenCenter(X);
        add(strumLine);

        textGroup = new FlxTypedGroup<FlxText>();
        add(textGroup);

        for(i in 0...keyCount)
        {
            var txt:FlxText = new FlxText(strumLine.members[i].x+(strumLine.members[i].width/3), strumLine.members[i].y+(strumLine.members[i].height/4)+10, 0, Init.keyBinds[keyCount-1][i], 48);
            txt.setFormat(AssetPaths.font("vcr"), 48, FlxColor.WHITE, CENTER);
            txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
            txt.scale.set(strumLine.members[i].scale.x + 0.3, strumLine.members[i].scale.y + 0.3);
            txt.scrollFactor.set();
            txt.fieldWidth = txt.width;
            textGroup.add(txt);
        }

        warnText = new FlxText(0, FlxG.height * 0.8, 0, "Press any key to change the selected bind to.", 24);
        warnText.setFormat(AssetPaths.font("vcr"), 24, FlxColor.WHITE, CENTER);
        warnText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
        warnText.screenCenter(X);
        warnText.scrollFactor.set();
        add(warnText);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        warnText.text = isChangingBind ? "Press any key to change the selected bind to." : "Click an arrow to change the bind for.\nPress ESCAPE or BACKSPACE to go back.";
        warnText.screenCenter(X);

        if(UIControls.justPressed("BACK"))
        {
            if(isChangingBind)
                isChangingBind = false;
            else
            {
                Init.saveSettings();
                close();
            }
        }
        else if(!isChangingBind)
        {
            strumLine.forEachAlive(function(strum:StrumNote) {
                if(FlxG.mouse.overlaps(strum))
                {
                    if(strum.alpha != 1)
                        FlxG.sound.play(scrollMenu);
                    strum.alpha = 1;
                    if(FlxG.mouse.justPressed)
                    {
                        bindToChange = strum.noteData;
                        isChangingBind = true;
                    }
                }
                else
                    strum.alpha = 0.6;
            });
        }
        else
        {
            if(FlxG.keys.justPressed.ANY)
            {
                var curKey:FlxKey = FlxG.keys.getIsDown()[0].ID;
                Init.keyBinds[strumLine.keyCount-1][bindToChange] = curKey;
                isChangingBind = false;

                textGroup.members[bindToChange].text = curKey.toString();

                FlxG.sound.play(confirmMenu);
            }
        }
    }
}