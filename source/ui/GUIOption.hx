package ui;

import Option.OptionType;
import flixel.group.FlxSpriteGroup;

class GUIOption extends FlxSpriteGroup
{
    public var saveData:String;
    public var type:OptionType = BOOL;

    public var alphabet:Alphabet;
    public var alphabet2:Alphabet;
    public var checkbox:CheckboxThingie;

    public var decimals:Int;
    public var multiplier:Float;
    public var minimum:Float;
    public var maximum:Float;
    public var values:Array<Dynamic> = [];

    public function new(x:Float, y:Float, text:String = "", bold:Bool = true, typed:Bool = false, saveData:String, type:OptionType = BOOL)
    {
        super();

        this.saveData = saveData;
        this.type = type;

        alphabet = new Alphabet(x, y, text, bold, typed);
        add(alphabet);

        switch(type)
        {
            case BOOL:
                alphabet.x += 150;
                alphabet.xAdd = 100;

                checkbox = new CheckboxThingie(0, 0, Init.getOption(saveData));
                checkbox.sprTracker = alphabet;
                checkbox.offsetX -= 120;
                checkbox.offsetY -= 35;
                add(checkbox);
            case ARRAY | NUMBER:
                alphabet2 = new Alphabet(alphabet.x, alphabet.y, text, false, typed);
                alphabet2.isMenuItem = true;
                alphabet2.targetY = alphabet.targetY;
                add(alphabet2);

                alphabet2.x += (alphabet.width * 1.3);
                alphabet2.xAdd += (alphabet.width * 1.35);
            default:
                trace("qwertyuiop");
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(alphabet2 != null)
        {
            alphabet2.isMenuItem = alphabet.isMenuItem;
            alphabet2.targetY = alphabet.targetY;
            alphabet2.alpha = alphabet.alpha;

            if(Init.getOption(saveData) != alphabet2.text)
            {
                alphabet2.destroyText();
                alphabet2.startText(Init.getOption(saveData), false);
            }
        }
    }
}