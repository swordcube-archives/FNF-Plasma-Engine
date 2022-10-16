package scenes.options;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import funkin.Alphabet;
import funkin.FNFCheckbox;
import misc.DiscordRPC;
import openfl.media.Sound;

class OptionsPage extends Subscene {
    var curSelected:Int = 0;
    
    var settings:Array<SettingData> = [];

    var grpAlphabet:FlxTypedGroup<Alphabet>;
    var grpAlphabetArrows:FlxTypedGroup<Alphabet>;
    var grpAlphabetValues:FlxTypedGroup<Alphabet>;
    var grpCheckbox:FlxTypedGroup<FNFCheckbox>;

    public function new(settings:Array<SettingData>) {
        super();
        this.settings = settings;
        for(s in this.settings) {
            switch(s.name) {
                case "Note Skin":
                    var str:String = "";
                    var basePath:String = '${Sys.getCwd()}assets/';
                    for(folder in FileSystem.readDirectory(basePath)) {
                        if(FileSystem.isDirectory(basePath+folder)) {
                            if(FileSystem.exists(basePath+folder+"/noteSkinList.txt")) {
                                str += Assets.get(TEXT, basePath+folder+"/noteSkinList.txt")+"\n";
                            }
                        }
                    }
                    s.values = CoolUtil.listFromText(str);
                case "Icon Style":
                    var str:String = "";
                    var basePath:String = '${Sys.getCwd()}assets/';
                    for(folder in FileSystem.readDirectory(basePath)) {
                        if(FileSystem.isDirectory(basePath+folder)) {
                            if(FileSystem.exists(basePath+folder+"/iconStyles.txt")) {
                                str += Assets.get(TEXT, basePath+folder+"/iconStyles.txt")+"\n";
                            }
                        }
                    }
                    s.values = CoolUtil.listFromText(str);
            }
        }
    }

    var descBox:FlxSprite;
    var descText:FlxText;

    var loadedSFX:Map<String, Sound> = [
        "scrollMenu"   => Assets.get(SOUND, Paths.sound("menus/scrollMenu")),
        "cancelMenu"   => Assets.get(SOUND, Paths.sound("menus/cancelMenu"))
    ];

    override function start() {
        var bg:Sprite = new Sprite().load(IMAGE, Paths.image("menuBGDesat"));
        bg.color = 0xFFEA71FD;
        add(bg);

        grpAlphabet = new FlxTypedGroup<Alphabet>();
        add(grpAlphabet);

        grpAlphabetArrows = new FlxTypedGroup<Alphabet>();
        add(grpAlphabetArrows);

        grpAlphabetValues = new FlxTypedGroup<Alphabet>();
        add(grpAlphabetValues);

        grpCheckbox = new FlxTypedGroup<FNFCheckbox>();
        add(grpCheckbox);

        for(i in 0...settings.length) {
            var setting = settings[i];

            var saveDataShit:String = setting.saveData != null ? setting.saveData : setting.name;

            var settingText:Alphabet = new Alphabet(0, (70 * i) + 30, setting.name, true);
            settingText.isMenuItem = true;
            settingText.targetY = i;
            settingText.ID = i;
            settingText.alpha = curSelected == i ? 1 : 0.6;
            grpAlphabet.add(settingText);

            switch(setting.type) {
                case "Checkbox":
                    settingText.x += 100;
                    settingText.xAdd += 100;
                    
                    var checkbox:FNFCheckbox = new FNFCheckbox(0, 0, Settings.get(saveDataShit));
                    checkbox.sprTracker = settingText;
                    checkbox.ID = i;
                    grpCheckbox.add(checkbox);
                case "Number", "Selector":
                    var cockTextG:Alphabet = new Alphabet(0, (70 * i) + 30, "<          >", false, 1, FlxColor.BLACK, false);
                    cockTextG.isMenuItem = true;
                    cockTextG.targetY = i;
                    cockTextG.x = settingText.width + 70;
                    cockTextG.xAdd = settingText.width + 70;
                    cockTextG.yAdd -= 50;
                    cockTextG.ID = i;
                    grpAlphabetArrows.add(cockTextG);
                
                    var cockText:Alphabet = new Alphabet(0, (70 * i) + 30, Settings.get(saveDataShit), false, 1, FlxColor.BLACK, false);
                    cockText.isMenuItem = true;
                    cockText.targetY = i;
                    cockText.x = settingText.width + 70;
                    cockText.xAdd = settingText.width + 70;
                    cockText.x += (cockTextG.width / 2) - (cockText.width / 2);
                    cockText.xAdd += (cockTextG.width / 2) - (cockText.width / 2);
                    cockText.yAdd -= 50;
                    cockText.ID = i;
                    grpAlphabetValues.add(cockText);
            }
        }

        descBox = new FlxSprite(30, FlxG.height - 65).makeGraphic(FlxG.width - 60, 1, FlxColor.BLACK);
        descBox.alpha = 0.8;
        add(descBox);
    
        descText = new FlxText(descBox.x + 5, descBox.y + 5, descBox.width - 10, "Description goes here lim foaw\nsdfhusufdhhAWslkjfhjsdlkjsfdhjlkjlk");
        descText.setFormat(Paths.font("funkin"), 25, FlxColor.WHITE, FlxTextAlign.CENTER);
        add(descText);

        changeSelection();
    }

    var holdTimer:Float = 0.0;

    override function process(delta:Float) {
        if(Controls.BACK_P) {
            FlxG.sound.play(loadedSFX["cancelMenu"]);
            close();
        }

        if(Controls.UI_UP_P)
            changeSelection(-1);

        if(Controls.UI_DOWN_P)
            changeSelection(1);

        if(Controls.UI_LEFT || Controls.UI_RIGHT) {
            holdTimer += delta;
            if(Controls.UI_LEFT_P || Controls.UI_RIGHT_P || holdTimer > 0.5) {
                var setting = settings[curSelected];
                var saveDataShit:String = setting.saveData != null ? setting.saveData : setting.name;
    
                switch(setting.type) {
                    case "Number":
                        var num:Float = Settings.get(saveDataShit);
                        num += Controls.UI_LEFT ? -setting.valueMult : setting.valueMult;
                        num = FlxMath.roundDecimal(num, 2);
                        if(num < setting.values[0]) num = setting.values[0];
                        if(num > setting.values[1]) num = setting.values[1];
                        Settings.set(saveDataShit, num);
    
                        var settingText = null;
                        for(i in grpAlphabet.members) {
                            if(curSelected == i.ID) {
                                settingText = i;
                                break;
                            }
                        }
                        var cockTextG = null;
                        for(i in grpAlphabetArrows.members) {
                            if(curSelected == i.ID) {
                                cockTextG = i;
                                break;
                            }
                        }
                        var cockText = null;
                        for(i in grpAlphabetValues.members) {
                            if(curSelected == i.ID) {
                                cockText = i;
                                break;
                            }
                        }
    
                        if(cockText != null) {
                            cockText.changeText(num+"");
                            cockText.xAdd = settingText.width + 70;
                            cockText.xAdd += (cockTextG.width / 2) - (cockText.width / 2);
                            cockText.snapX = true;
                        }
                    case "Selector":
                        var index:Int = setting.values.indexOf(Settings.get(saveDataShit));
                        index += Controls.UI_LEFT ? -1 : 1;
                        
                        if(index < 0)
                            index = setting.values.length - 1;
        
                        if(index > setting.values.length - 1)
                            index = 0;
        
                        var dumb:String = setting.values[index];
                        Settings.set(saveDataShit, dumb);
    
                        var settingText = null;
                        for(i in grpAlphabet.members) {
                            if(curSelected == i.ID) {
                                settingText = i;
                                break;
                            }
                        }
                        var cockTextG = null;
                        for(i in grpAlphabetArrows.members) {
                            if(curSelected == i.ID) {
                                cockTextG = i;
                                break;
                            }
                        }
                        var cockText = null;
                        for(i in grpAlphabetValues.members) {
                            if(curSelected == i.ID) {
                                cockText = i;
                                break;
                            }
                        }
    
                        if(cockText != null) {
                            cockText.changeText(dumb);
                            cockText.xAdd = settingText.width + 70;
                            cockText.xAdd += (cockTextG.width / 2) - (cockText.width / 2);
                            cockText.snapX = true;
                        }
                }
    
                if(holdTimer > 0.5)
                    holdTimer = 0.475;
            }
        } else {
            holdTimer = 0;
        }

        if(Controls.ACCEPT_P) {
            var setting = settings[curSelected];
            
            switch(setting.type) {
                case "Checkbox":
                    var saveDataShit:String = setting.saveData != null ? setting.saveData : setting.name;
                    Settings.set(saveDataShit, !Settings.get(saveDataShit));
    
                    var checkbox:FNFCheckbox = null;
                    for(i in grpCheckbox.members) {
                        if(curSelected == i.ID) {
                            checkbox = i;
                            break;
                        }
                    }
                    checkbox.status = Settings.get(saveDataShit);
                    checkbox.refresh();
            }
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if(curSelected < 0)
            curSelected = grpAlphabet.length-1;
        if(curSelected > grpAlphabet.length-1)
            curSelected = 0;

        for(i in 0...grpAlphabet.members.length) {
            grpAlphabet.members[i].alpha = curSelected == grpAlphabet.members[i].ID ? 1 : 0.6;
            grpAlphabet.members[i].targetY = grpAlphabet.members[i].ID - curSelected;
        }

        for(i in 0...grpAlphabetArrows.members.length) {
            grpAlphabetArrows.members[i].alpha = curSelected == grpAlphabetArrows.members[i].ID ? 1 : 0.6;
            grpAlphabetArrows.members[i].targetY = grpAlphabetArrows.members[i].ID - curSelected;
        }

        for(i in 0...grpAlphabetValues.members.length) {
            grpAlphabetValues.members[i].alpha = curSelected == grpAlphabetValues.members[i].ID ? 1 : 0.6;
            grpAlphabetValues.members[i].targetY = grpAlphabetValues.members[i].ID - curSelected;
        }

        descText.text = settings[curSelected].desc;
        descBox.scale.y = descText.height + 10;
        descBox.updateHitbox();
        descBox.y = FlxG.height - (descBox.height + 15);
        descText.y = descBox.y + 3;
        descText.text += "\n     ";

        DiscordRPC.changePresence(
            "In the Options Menu",
            "Changing "+settings[curSelected].page+" > "+settings[curSelected].name
        );

        FlxG.sound.play(loadedSFX["scrollMenu"]);
    }
}