package funkin.states.options;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.states.options.Option;

class OptionsPage extends BaseOptionsPage {
    var grpAlphabet:FlxTypedGroup<Alphabet>;
    var grpCheckbox:FlxTypedGroup<Checkbox>;
    var grpAlphabetValues:FlxTypedGroup<Alphabet>;
    var grpArrows:FlxTypedGroup<TrackingSprite>;

    var valMap:Map<Int, Alphabet> = [];
    var boxMap:Map<Int, Checkbox> = [];

    var descBox:Sprite;
    var descText:FlxText;

    var optionsList:Array<Option> = [];

    override function create() {
        super.create();

        grpAlphabet = new FlxTypedGroup<Alphabet>();
        add(grpAlphabet);

        grpCheckbox = new FlxTypedGroup<Checkbox>();
        add(grpCheckbox);

        grpAlphabetValues = new FlxTypedGroup<Alphabet>();
        add(grpAlphabetValues);

        grpArrows = new FlxTypedGroup<TrackingSprite>();
        add(grpArrows);

        descBox = new Sprite(30, FlxG.height - 65).makeGraphic(FlxG.width - 60, 1, FlxColor.BLACK);
        descBox.alpha = 0.8;
        add(descBox);

        descText = new FlxText(descBox.x + 5, descBox.y + 5, descBox.width - 10, "Description goes here lim foaw\nsdfhusufdhhAWslkjfhjsdlkjsfdhjlkjlk");
        descText.setFormat(Paths.font("funkin.ttf"), 25, FlxColor.WHITE, CENTER);
        add(descText);
    }

    public function addOption(option:Option) {
        optionsList.push(option);
        
        var alphabet = new Alphabet(0, (70 * grpAlphabet.length) + 30, Bold, option.name);
        alphabet.isMenuItem = true;
        alphabet.targetY = grpAlphabet.length;
        alphabet.ID = grpAlphabet.length;
        grpAlphabet.add(alphabet);

        switch(option.type) {
            case Checkbox:
                alphabet.x += 100;
                alphabet.xAdd += 100;

                var checkbox = new Checkbox(0, 0, Settings.get(option.name));
                checkbox.tracked = alphabet;
                checkbox.trackingOffset.set(-120, -40);
                checkbox.trackingMode = LEFT;
                checkbox.ID = grpAlphabet.length-1;
                grpCheckbox.add(checkbox);
                boxMap[checkbox.ID] = checkbox;

            case Selector, Number:
                var valueText = new Alphabet(0, (70 * grpAlphabet.length-1) + 30, Default, Settings.get(option.name));
                valueText.isMenuItem = true;
                valueText.targetY = grpAlphabet.length-1;
                valueText.x += alphabet.width + 150;
                valueText.xAdd += alphabet.width + 150;
                valueText.y += 10;
                valueText.yAdd += 10;
                valueText.ID = grpAlphabet.length-1;
                valueText.color = FlxColor.BLACK;
                grpAlphabetValues.add(valueText);
                valMap[valueText.ID] = valueText;

                var arrow = new TrackingSprite().load(SPARROW, Paths.image("ui/storyAssets"));
                arrow.tracked = valueText;
                arrow.addAnim("idle", "arrow left", 24, true);
                arrow.playAnim("idle");
                arrow.trackingMode = LEFT;
                arrow.trackingOffset.set(-(arrow.width + 5), -5);
                grpArrows.add(arrow);

                var arrow = new TrackingSprite().load(SPARROW, Paths.image("ui/storyAssets"));
                arrow.tracked = valueText;
                arrow.addAnim("idle", "arrow right", 24, true);
                arrow.playAnim("idle");
                arrow.trackingMode = RIGHT;
                arrow.trackingOffset.set(5, -5);
                grpArrows.add(arrow);

            default:
                Console.error("This option: "+option.name+" has an invalid type and cannot be added!");
        }
    }

    var curSelected:Int = 0;

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if(curSelected < 0) curSelected = grpAlphabet.length-1;
        if(curSelected > grpAlphabet.length-1) curSelected = 0;

        for(i in 0...grpAlphabet.length) {
            var text:Alphabet = grpAlphabet.members[i];
            text.targetY = text.ID - curSelected;
            text.alpha = curSelected == text.ID ? 1 : 0.6;
        }
        for(i in 0...grpAlphabetValues.length) {
            var text:Alphabet = grpAlphabetValues.members[i];
            text.targetY = text.ID - curSelected;
            text.alpha = curSelected == text.ID ? 1 : 0.6;
        }
        FlxG.sound.play(Assets.load("SOUND", Paths.sound("menus/scrollMenu")));

        descText.text = optionsList[curSelected].desc;
        descBox.scale.y = descText.height + 10;
        descBox.updateHitbox();
        descBox.y = FlxG.height - (descBox.height + 15);
        descText.y = descBox.y + 3;
        descText.text += "\n     ";
    }

    var holdTimer:Float = 0.0;

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(Controls.getP("ui_up")) changeSelection(-1);
        if(Controls.getP("ui_down")) changeSelection(1);
        if (Controls.get("ui_left") || Controls.get("ui_right")) {
            holdTimer += elapsed;
            if ((Controls.getP("ui_left") || Controls.getP("ui_right")) || holdTimer > 0.5) {
                var option:Option = optionsList[curSelected];
                switch(option.type) {
                    case Selector:
                        var curIndex:Int = option.values.indexOf(Settings.get(option.name));
                        var mult:Int = Std.int(CoolUtil.getBoolAxis(Controls.get("ui_right"), Controls.get("ui_left")));
                        curIndex = Std.int(FlxMath.bound(curIndex + mult, 0, option.values.length-1));
                        Settings.set(option.name, option.values[curIndex]);

                        var text:Alphabet = valMap.get(curSelected);
                        if(text != null) text.text = option.values[curIndex];

                    case Number:
                        var curNumber:Float = Settings.get(option.name);
                        var mult:Float = CoolUtil.getBoolAxis(Controls.get("ui_right"), Controls.get("ui_left")) * option.increment;
                        curNumber = MathUtil.roundDecimal(FlxMath.bound(curNumber + mult, option.limits[0], option.limits[1]), option.decimals);
                        Settings.set(option.name, curNumber);

                        var text:Alphabet = valMap.get(curSelected);
                        if(text != null) text.text = curNumber+"";

                    default:
                }
            }
            if(holdTimer > 0.5) holdTimer = 0.425;
        } else holdTimer = 0.0;

        if(Controls.getP("accept")) {
            var option:Option = optionsList[curSelected];
            switch(option.type) {
                case Checkbox:
                    Settings.set(option.name, !Settings.get(option.name));
                    var checkbox:Checkbox = boxMap.get(curSelected);
                    if(checkbox != null) checkbox.checked = Settings.get(option.name);
    
                default:
            }
        }
    }
}