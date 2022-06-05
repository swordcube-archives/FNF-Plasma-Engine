package states;

import base.Controls;
import base.MusicBeat.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import ui.Alphabet;
import ui.CheckboxThingie;
import ui.GUIOption;

class OptionsMenu extends MusicBeatState
{
    var menuBG:FlxSprite;

    var scrollMenu:Dynamic;
    var cancelMenu:Dynamic;

    var grpAlphabet:FlxTypedGroup<GUIOption>;

    var selectorBox:FlxSprite;
    var selectorArrows:Map<String, Alphabet> = null;
    var selectorText:Alphabet;

    var pages:Array<String> = [
        "Preferences",
        "Appearance"
    ];

    static var curSelected:Int = 0;
    static var curPage:Int = 0;

    var selectingPage:Bool = false;
    
    override public function create()
    {
        super.create();

        persistentUpdate = true;
        persistentDraw = true;
        
        menuBG = new FlxSprite().loadGraphic(GenesisAssets.getAsset('menuBGDesat', IMAGE));
        menuBG.color = 0xFFEA71FD;
        add(menuBG);

        FlxG.sound.playMusic(GenesisAssets.getAsset('optionsMenu', MUSIC));
        
        scrollMenu = GenesisAssets.getAsset('menus/scrollMenu', SOUND);
        cancelMenu = GenesisAssets.getAsset('menus/cancelMenu', SOUND);

        grpAlphabet = new FlxTypedGroup<GUIOption>();
        add(grpAlphabet);

        selectorBox = new FlxSprite().makeGraphic(FlxG.width, 80, FlxColor.BLACK);
        selectorBox.alpha = 0.6;
        add(selectorBox);

        selectorBox.y = FlxG.height - selectorBox.height;

        selectorArrows = [
            "left" => new Alphabet(0, 0, "<", true),
            "right" => new Alphabet(0, 0, ">", true)
        ];

        var funnyMult:Float = 500;

        selectorArrows["left"].screenCenter(X);
        selectorArrows["left"].x -= funnyMult;
        selectorArrows["left"].y = selectorBox.y + 5;
        selectorArrows["left"].scale.set(0.7, 0.7);
        add(selectorArrows["left"]);

        selectorArrows["right"].screenCenter(X);
        selectorArrows["right"].x += funnyMult;
        selectorArrows["right"].y = selectorBox.y + 5;
        selectorArrows["right"].scale.set(0.7, 0.7);
        add(selectorArrows["right"]);

        selectorText = new Alphabet(0, selectorBox.y + 7, "Testing", true, false, 0.8);
        selectorText.screenCenter(X);
        selectorText.scale.set(0.7, 0.7);
        add(selectorText);

        changePage();
        changeSelection();
    }

    public function changeSelection(change:Int = 0)
    {
        if(grpAlphabet.length > 0)
        {
            curSelected += change;
            if(curSelected < 0)
                curSelected = grpAlphabet.members.length - 1;
            if(curSelected > grpAlphabet.members.length - 1)
                curSelected = 0;

            var i:Int = 0;
            grpAlphabet.forEachAlive(function(a:GUIOption) {
                a.alphabet.targetY = i - curSelected;
                if(curSelected == i)
                    a.alphabet.alpha = 1;
                else
                    a.alphabet.alpha = 0.6;
                i++;
            });
        }

        FlxG.sound.play(scrollMenu);
    }

    public function changePage(change:Int = 0)
    {
        curPage += change;
        if(curPage < 0)
            curPage = pages.length - 1;
        if(curPage > pages.length - 1)
            curPage = 0;

        selectorText.alpha = 0;
        selectorText.y = selectorBox.y - 3;
        selectorText.destroyText();
        selectorText.startText(pages[curPage], false);
        selectorText.scale.set(0.8, 0.8);
        selectorText.screenCenter(X);

        grpAlphabet.forEachAlive(function(a:GUIOption) {
            grpAlphabet.remove(a);
            a.kill();
            a.destroy();
        });

        grpAlphabet.clear();

        var i:Int = 0;
        for(rawOption in Init.options.get(pages[curPage]).keys())
        {
            var option = Init.options.get(pages[curPage]).get(rawOption);
            var newOption:GUIOption = new GUIOption(0, (70 * i) + 30, option.title, true, false, rawOption, option.type);
			newOption.alphabet.isMenuItem = true;
			newOption.alphabet.targetY = i;
            newOption.decimals = option.decimals;
            newOption.multiplier = option.multiplier;
            newOption.minimum = option.minimum;
            newOption.maximum = option.maximum;
            newOption.values = option.values;
            grpAlphabet.add(newOption);
            i++;
        }

        curSelected = 0;
        changeSelection();

        FlxG.sound.play(scrollMenu);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(Controls.isPressed("BACK", JUST_PRESSED))
        {
            persistentUpdate = false;
            persistentDraw = true;
            
            FlxG.sound.play(cancelMenu);
            FlxG.sound.playMusic(GenesisAssets.getAsset('freakyMenu', MUSIC));
            States.switchState(this, new MainMenu());
        }

        if(!selectingPage)
        {
            selectorBox.alpha = 0.6 / 2;
            selectorArrows["left"].alpha = 0.6;
            selectorArrows["right"].alpha = 0.6;
            selectorText.alpha = 0.6;
        }
        else
        {
            if(grpAlphabet.length > 0)
            {
                grpAlphabet.forEachAlive(function(a:GUIOption) {
                    a.alphabet.alpha = 0.4;
                });
            }
            selectorBox.alpha = 0.6;
            selectorArrows["left"].alpha = 1;
            selectorArrows["right"].alpha = 1;
            selectorText.alpha = 1;
        }

        if(FlxG.keys.justPressed.SPACE)
        {
            selectingPage = !selectingPage;
            changeSelection();
        }

        if(Controls.isPressed("UI_LEFT", JUST_PRESSED))
        {
            if(selectingPage)
                changePage(-1);
        }

        if(Controls.isPressed("UI_RIGHT", JUST_PRESSED))
        {
            if(selectingPage)
                changePage(1);
        }

        if(Controls.isPressed("UI_UP", JUST_PRESSED))
        {
            if(!selectingPage)
                changeSelection(-1);
        }

        if(Controls.isPressed("UI_DOWN", JUST_PRESSED))
        {
            if(!selectingPage)
                changeSelection(1);
        }

        // Modifying Options
        modifyCurOption(elapsed);

        selectorText.y = FlxMath.lerp(selectorText.y, selectorBox.y + 15, 0.2);
        selectorText.alpha = FlxMath.lerp(selectorText.alpha, 1, 0.2);
    }
    
    var holdTimer:Float = 0;

    function modifyCurOption(elapsed:Float)
    {
        var option = grpAlphabet.members[curSelected];
        switch(option.type)
        {
            case BOOL:
                if(!selectingPage && Controls.isPressed("ACCEPT", JUST_PRESSED) && !FlxG.keys.justPressed.SPACE)
                {
                    Init.setOption(option.saveData, !Init.getOption(option.saveData));
                    option.checkbox.daValue = Init.getOption(option.saveData);
                    option.checkbox.refreshAnim(option.checkbox.daValue);

                    FlxG.autoPause = Init.getOption("auto-pause");
                }
            case NUMBER:
                if(selectingPage) return;
                
                var left = Controls.isPressed("UI_LEFT", PRESSED);
                var right = Controls.isPressed("UI_RIGHT", PRESSED);

                var leftP = Controls.isPressed("UI_LEFT", JUST_PRESSED);
                var rightP = Controls.isPressed("UI_RIGHT", JUST_PRESSED);

                if(left || right)
                {
                    holdTimer += elapsed;
                    if((leftP || rightP) || holdTimer > 0.5)
                    {
                        var mult:Float = left ? -option.multiplier : option.multiplier;
                        var value:Float = Init.getOption(option.saveData) + mult;
                        if(value < option.minimum)
                            value = option.minimum;
                        if(value > option.maximum)
                            value = option.maximum;

                        value = FlxMath.roundDecimal(value, option.decimals);

                        Init.setOption(option.saveData, value);
                    }
                }
                else
                    holdTimer = 0;
            default:
                trace("your mother");
        }
    }
}