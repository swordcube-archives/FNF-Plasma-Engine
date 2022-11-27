package funkin.options.screens;

import funkin.system.MathUtil;
import funkin.ui.UIArrow;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import funkin.ui.FNFCheckbox;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;
import funkin.options.types.BaseOption;
import funkin.options.types.ListOption;
import funkin.options.types.GameplayControl;
import funkin.options.types.GeneralControl;
import flixel.FlxSprite;
import funkin.substates.FNFSubState;

// this code is stupid as hell but i don't wanna fix that rn
class OptionScreen extends FNFSubState {
    public var curSelected:Int = 0;

    public var grpTitles:FlxTypedGroup<Alphabet>;
    public var grpCategories:FlxTypedGroup<Alphabet>;

    public var checkboxMap:Map<Int, FNFCheckbox> = [];
    public var valueTextMap:Map<Int, Alphabet> = [];

    public var controlTextMap:Map<Int, Array<Alphabet>> = [];

    public var categories:Array<String> = [];
    public var options:Map<String, Array<Dynamic>> = [];
    public var generalOptions:Array<Dynamic> = [];

    public var amountOfOptions:Int = 0;
    public var camFollow:FlxObject;

    public var bg:FlxSprite;

    public var bindSelected:Int = 0;
    public var canInteract:Bool = true;

    override function create() {
        super.create();
        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;
        
		bg = new FlxSprite().loadGraphic(Assets.load(IMAGE, Paths.image('menuBGDesat')));
        bg.color = 0xFFea71fd;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
        bg.scrollFactor.set();
		add(bg);

        // almost forgot you can do this in haxe
        add(grpTitles = new FlxTypedGroup<Alphabet>());
        add(grpCategories = new FlxTypedGroup<Alphabet>());

        var optionID:Int = 0;
        var bullShit:Int = 0;
        for(category in categories) {
            if(bullShit > 0) bullShit++;
            var pos:FlxPoint = new FlxPoint(90, bullShit * 85);
            var alphabet = new Alphabet(pos.x, pos.y, Bold, category);
            alphabet.screenCenter(X);
            grpCategories.add(alphabet);
            bullShit += 2;

            for(item in options[category]) {
                var pos:FlxPoint = new FlxPoint(90, bullShit * 85);
                var alphabet = new Alphabet(pos.x, pos.y, Bold, item.title);
                alphabet.ID = optionID;
                grpTitles.add(alphabet);

                switch(Type.getClass(item)) {
                    case BoolOption:
                        alphabet.x += 130;

                        var saveData:String = item.saveData != null ? item.saveData : item.title;
                        var box = new FNFCheckbox(pos.x - 100, pos.y - 50, prefs.get(saveData));
                        box.tracked = alphabet;
                        box.trackingMode = LEFT;
                        box.trackingOffset.set(-100, -40);
                        box.ID = optionID;
                        checkboxMap[optionID] = box;
                        add(box);

                    case NumberOption, ListOption:
                        alphabet.x += 80;

                        var arrow = new UIArrow(0, 0, false);
                        arrow.tracked = alphabet;
                        arrow.trackingMode = LEFT;
                        arrow.trackingOffset.set(-(arrow.width + 5), -10);
                        arrow.control = "UI_LEFT";
                        arrow.ID = optionID;
                        arrow.onJustPressed = function() {
                            if(curSelected == arrow.ID)
                                arrow.playAnim("press");
                        }
                        add(arrow);

                        var arrow = new UIArrow(0, 0, true);
                        arrow.tracked = alphabet;
                        arrow.trackingMode = RIGHT;
                        arrow.trackingOffset.set(5, -10);
                        arrow.control = "UI_RIGHT";
                        arrow.ID = optionID;
                        arrow.onJustPressed = function() {
                            if(curSelected == arrow.ID)
                                arrow.playAnim("press");
                        }
                        add(arrow);

                        var saveData:String = item.saveData != null ? item.saveData : item.title;
                        var valText = new Alphabet(alphabet.x + (alphabet.width + 80), alphabet.y, Bold, prefs.get(saveData));
                        valText.ID = optionID;
                        valueTextMap[optionID] = valText;
                        add(valText);

                    case GameplayControl:
                        var itemData:GameplayControl = cast item;

                        alphabet.x += 150;
                        alphabet.font = Default;
                        alphabet.text = itemData.title;
                        alphabet.color = FlxColor.BLACK;

                        var control = new Alphabet(alphabet.x + 400, alphabet.y, Default, CoolUtil.keyToString(controls.list[itemData.saveData][itemData.keyIndex]));
                        control.ID = optionID;
                        control.color = FlxColor.BLACK;
                        add(control);

                        controlTextMap[optionID] = [control];

                    case GeneralControl:
                        alphabet.x += 150;
                        alphabet.font = Default;
                        alphabet.text = item.title;
                        alphabet.color = FlxColor.BLACK;

                        var saveData:String = item.saveData;

                        var control1 = new Alphabet(alphabet.x + 250, alphabet.y, Default, CoolUtil.keyToString(controls.list[saveData][0]));
                        control1.ID = optionID;
                        control1.color = FlxColor.BLACK;
                        add(control1);

                        var control2 = new Alphabet(alphabet.x + 550, alphabet.y, Default, CoolUtil.keyToString(controls.list[saveData][1]));
                        control2.ID = optionID;
                        control2.color = FlxColor.BLACK;
                        add(control2);

                        controlTextMap[optionID] = [control1, control2];
                }
                generalOptions.push(item);
                amountOfOptions++;
                optionID++;
                bullShit++;
            }
        }

        camFollow = new FlxObject(0,0,1,1);
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 0.16);
        changeSelection();
    }

    var holdTimer:Float = 0.0;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(canInteract) {
            if(controls.getP("UI_UP")) changeSelection(-1);
            if(controls.getP("UI_DOWN")) changeSelection(1);

            if(controls.get("UI_LEFT") || controls.get("UI_RIGHT")) {
                holdTimer += elapsed;
                if(controls.getP("UI_LEFT") || controls.getP("UI_RIGHT") || holdTimer > 0.5) {
                    var option:Dynamic = generalOptions[curSelected];
                    var saveData:String = option.saveData != null ? option.saveData : option.title;
                    var prefs = PlayerSettings.prefs;
                    switch(Type.getClass(option)) {
                        case NumberOption:
                            var value:Float = prefs.get(saveData);
                            value += controls.get("UI_LEFT") ? -option.increment : option.increment;
                            value = FlxMath.bound(MathUtil.roundDecimal(value, option.decimals), option.limits[0], option.limits[1]);
                            prefs.set(saveData, value);
                            valueTextMap[curSelected].text = value+"";
                            if(option.updateCallback != null) option.updateCallback(value);

                        case ListOption:
                            var value:String = prefs.get(saveData);
                            var index:Int = option.values.indexOf(value);
                            var inc:Int = controls.get("UI_LEFT") ? -1 : 1;
                            index = Std.int(FlxMath.bound(index+inc, 0, option.values.length-1));
                            prefs.set(saveData, option.values[index]);
                            valueTextMap[curSelected].text = option.values[index]+"";
                            if(option.updateCallback != null) option.updateCallback(option.values[index]);

                        case GameplayControl:
                            bindSelected = 0;

                        case GeneralControl:
                            var inc:Int = controls.get("UI_LEFT") ? -1 : 1;
                            bindSelected = Std.int(FlxMath.bound(bindSelected+inc, 0, 1));

                            var val = controlTextMap[curSelected];
                            if(val != null) {
                                var cum:Int = 0;
                                for(ass in val) {
                                    ass.alpha = (curSelected == ass.ID && bindSelected == cum) ? 1 : 0.6;
                                    cum++;
                                }
                            }
                    }
                    if(holdTimer > 0.5) holdTimer = 0.425;
                }
            } else holdTimer = 0;

            if(controls.getP("ACCEPT")) {
                var option:Dynamic = generalOptions[curSelected];
                var saveData:String = option.saveData != null ? option.saveData : option.title;
                var prefs = PlayerSettings.prefs;
                switch(Type.getClass(option)) {
                    case BoolOption:
                        var casted:BoolOption = cast option;
                        prefs.set(saveData, !prefs.get(saveData));
                        checkboxMap[curSelected].checked = prefs.get(saveData);
                        if(prefs.get("Flashing Lights"))
                            FlxFlicker.flicker(grpTitles.members[curSelected], 0.5, 0.06, true, false);
                        if(casted.updateCallback != null) casted.updateCallback(cast prefs.get(saveData));
                        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
                }
            }
            if(controls.getP("BACK")) {
                goBack();
            }
        }
    }

    public function goBack() {
        camFollow.setPosition(0, 0);
        FlxG.camera.scroll.set(0, 0);
        FlxG.camera.follow(null, null, 0);
        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
        close();
    }

    function changeSelection(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, amountOfOptions-1);

        if(generalOptions[curSelected] is GameplayControl)
            bindSelected = 0;

        grpTitles.forEach(function(a:Alphabet) {
            a.alpha = curSelected == a.ID ? 1 : 0.6;
            var val = valueTextMap[a.ID];
            if(val != null) val.alpha = a.alpha;
            var val = controlTextMap[a.ID];
            if(val != null) {
                var cum:Int = 0;
                for(ass in val) {
                    ass.alpha = (curSelected == a.ID && bindSelected == cum) ? 1 : 0.6;
                    cum++;
                }
            }
            if(curSelected == a.ID)
                camFollow.setPosition(0, a.y + 85);
        });
        camFollow.screenCenter(X);

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }
}