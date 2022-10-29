package funkin.states.substates;

import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;

class ModSelection extends FunkinSubState {
    var initialMod:String = Paths.currentMod;
    
    var icon:Sprite;
    var title:FlxText;
    var desc:FlxText;

    var arrowLeft:Alphabet;
    var arrowRight:Alphabet;

    var curSelected:Int = 0;
    var availableMods:Map<String, ModPackData> = [];
    var selectedText:FlxText;
    var modNames:Array<String> = [];

    override function create() {
        super.create();

        var bg:Sprite = new Sprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.alpha = 0.6;
        add(bg);

        var card:Sprite = new Sprite().load(IMAGE, Paths.image("modCardBG"));
        card.scale.set(0.7, 0.7);
        card.updateHitbox();
        card.screenCenter();
        card.scrollFactor.set();
        add(card);

        var basePath:String = '${Sys.getCwd()}mods/';
        for(mod in FileSystem.readDirectory(basePath)) {
            if(FileSystem.isDirectory(basePath+mod) && FileSystem.exists(Paths.json('pack', mod))) {
                var data:ModPackData = TJSON.parse(Assets.load(TEXT, Paths.json('pack', mod)));
                modNames.push(mod);
                availableMods[mod] = data;
            }
        }
        curSelected = modNames.indexOf(Paths.currentMod);
        var data:ModPackData = availableMods[Paths.currentMod];

        icon = new Sprite(card.x + 10, card.y + 10).load(IMAGE, Paths.image("pack", false));
        icon.setGraphicSize(100);
        icon.updateHitbox();
        icon.scrollFactor.set();
        add(icon);

        title = new FlxText(icon.x + (icon.width + 20), icon.y + (icon.height / 2), 0, data.name+"\n  ");
        title.setFormat(Paths.font("funkin.ttf"), 64);
        title.scrollFactor.set();
        title.antialiasing = Settings.get("Antialiasing");
        title.y -= title.height / 4;
        add(title);

        desc = new FlxText(icon.x, icon.y + (icon.height + 10), card.width - 10, data.desc+"\n   ");
        desc.setFormat(Paths.font("funkin.ttf"), 24);
        desc.scrollFactor.set();
        desc.antialiasing = Settings.get("Antialiasing");
        add(desc);

        @:privateAccess
        var warn = new FlxText(card.x + (card.width - 10), card.y + (card.height - 10), "Press "+FlxKey.toStringMap[Controls.list["accept"][0]]+" or "+FlxKey.toStringMap[Controls.list["accept"][1]]+" to select this mod.\nPress "+FlxKey.toStringMap[Controls.list["back"][0]]+" or "+FlxKey.toStringMap[Controls.list["back"][1]]+" to cancel and exit this menu.\n   ");
        warn.setFormat(Paths.font("funkin.ttf"), 18, FlxColor.WHITE, RIGHT);
        warn.scrollFactor.set();
        warn.antialiasing = Settings.get("Antialiasing");
        warn.x -= warn.width + 10;
        warn.y -= warn.height - 10;
        add(warn);

        arrowLeft = new Alphabet(35, 0, Bold, "<", 1.5);
        arrowLeft.screenCenter(Y);
        arrowLeft.scrollFactor.set();
        add(arrowLeft);

        arrowRight = new Alphabet(FlxG.width - 35, 0, Bold, ">", 1.5);
        arrowRight.screenCenter(Y);
        arrowRight.x -= arrowRight.width;
        arrowRight.scrollFactor.set();
        add(arrowRight);

        selectedText = new FlxText(0,FlxG.height - 90,0,"?/?");
        selectedText.size = 32;
        selectedText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
        selectedText.scrollFactor.set();
        selectedText.antialiasing = Settings.get("Antialiasing");
        selectedText.screenCenter(X);
        add(selectedText);

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        selectedText.text = (curSelected+1)+"/"+modNames.length;
        selectedText.screenCenter(X);

        if(Controls.getP("ui_left"))
            changeSelection(-1);

        if(Controls.getP("ui_right"))
            changeSelection(1);

        if(Controls.getP("back")) {
            Paths.currentMod = initialMod;
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
            close();
        }
        if(Controls.getP("accept")) {
            FlxG.save.data.currentMod = Paths.currentMod;
            FlxG.save.flush();
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
            Main.resetState();
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if(curSelected < 0)
            curSelected = modNames.length-1;
        if(curSelected > modNames.length-1)
            curSelected = 0;

        Paths.currentMod = modNames[curSelected];

        var data = availableMods[Paths.currentMod];
        icon.load(IMAGE, Paths.image("pack", false));
        icon.setGraphicSize(100);
        icon.updateHitbox();

        title.text = data.name+"\n  ";
        desc.text = data.desc+"\n  ";

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }
}