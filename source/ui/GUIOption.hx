package ui;

import Option.OptionType;
import flixel.group.FlxSpriteGroup;

class GUIOption extends FlxSpriteGroup
{
    public var saveData:String;
    public var type:OptionType = BOOL;

    public var alphabet:Alphabet;
    public var checkbox:CheckboxThingie;

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
            default:
                trace("qwertyuiop");
        }
    }
}