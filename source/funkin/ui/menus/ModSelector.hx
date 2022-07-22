package funkin.ui.menus;

#if MODS_ALLOWED
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.game.GlobalVariables;
import funkin.systems.FunkinAssets;
import funkin.systems.Paths;
import funkin.systems.UIControls;
import openfl.display.BitmapData;
import softmod.SoftMod;

using StringTools;

class ModSelector extends FlxGroup
{
    public var onChangeSelection:Void->Void;

    public var icon:FlxSprite;
    public var text:FlxText;

    public var ctrlKey:FlxKey = CONTROL;

    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(400, 50, FlxColor.BLACK);
        bg.setPosition(FlxG.width - bg.width, FlxG.height - bg.height);
        bg.alpha = 0.6;
        add(bg);

        icon = new FlxSprite();

        var curMod:String = SoftMod.modsList[GlobalVariables.selectedMod];

        var iconBMP:BitmapData = BitmapData.fromFile('${Sys.getCwd()}${SoftMod.modsFolder}/${curMod}/softmod_icon.png');
        if(iconBMP != null)
        {
            icon.loadGraphic(FlxGraphic.fromBitmapData(iconBMP));
        }
        else
        {
            icon.loadGraphic(FunkinAssets.getImage(Paths.image('default_mod_icon')));
        }

        icon.setGraphicSize(Std.int(bg.height), Std.int(bg.height));
        icon.updateHitbox();

        icon.setPosition(bg.x, bg.y);
        add(icon);

        text = new FlxText(icon.x + (icon.width + 10), icon.y + 5, 0, curMod, 24);
        text.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        text.borderSize = 2;
        add(text);

        var cocktext = new FlxText(text.x, icon.y + 30, 0, "CTRL + LEFT/RIGHT to switch mods", 14);
        cocktext.setFormat(Paths.font("vcr"), 14, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        cocktext.borderSize = 2;
        add(cocktext);

        changeSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if(FlxG.keys.checkStatus(ctrlKey, PRESSED) && UIControls.justPressed("LEFT"))
            changeSelection(-1);

        if(FlxG.keys.checkStatus(ctrlKey, PRESSED) && UIControls.justPressed("RIGHT"))
            changeSelection(1);
    }

    public function changeSelection(change:Int = 0)
    {
        GlobalVariables.selectedMod += change;
        if(GlobalVariables.selectedMod < 0)
            GlobalVariables.selectedMod = SoftMod.modsList.length-1;

        if(GlobalVariables.selectedMod > SoftMod.modsList.length-1)
            GlobalVariables.selectedMod = 0;

        var curMod:String = SoftMod.modsList[GlobalVariables.selectedMod];

        #if windows
        var path:String = '${Sys.getCwd()}${SoftMod.modsFolder}/${curMod}/softmod_icon.png'.replace("/", "\\");
        #else
        var path:String = '${Sys.getCwd()}${SoftMod.modsFolder}/${curMod}/softmod_icon.png';
        #end

        var iconBMP:BitmapData = BitmapData.fromFile(path);
        if(iconBMP != null)
        {
            icon.loadGraphic(FlxGraphic.fromBitmapData(iconBMP));
            trace("loaded mod icon successfully!");
        }
        else
        {
            icon.loadGraphic(FunkinAssets.getImage(Paths.image('default_mod_icon')));
            trace("mod icon couldn't load, loading default icon instead...");
        }

        text.text = curMod;

        if(onChangeSelection != null)
            onChangeSelection();
    }
}
#end