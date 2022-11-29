package funkin.substates;

import funkin.ui.Alphabet;
import funkin.system.FNFSprite;
import funkin.system.ModData;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;

class ModSelection extends FNFSubState {
    var initialMod:String = Paths.currentMod;
    
    var icon:FNFSprite;
    var title:FlxText;
    var desc:FlxText;

    var arrowLeft:Alphabet;
    var arrowRight:Alphabet;

    var curSelected:Int = 0;
    var availableMods:Map<String, PackData> = [];
    var selectedText:FlxText;
    var modNames:Array<String> = [];

    var unsafeText:FlxText;

    override function create() {
        super.create();

        var bg = new FNFSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.alpha = 0.6;
        add(bg);

        var card = new FNFSprite().load(IMAGE, Paths.image("modCardBG"));
        card.scale.set(0.7, 0.7);
        card.updateHitbox();
        card.screenCenter();
        card.scrollFactor.set();
        add(card);

        var paths:Array<String> = [
            '${Sys.getCwd()}mods/'
        ];
        if(Main.developerMode) paths.push('${Sys.getCwd()}../../../../mods/');
        for(basePath in paths) {
            for(mod in FileSystem.readDirectory(basePath)) {
                if(FileSystem.isDirectory(basePath+mod) && FileSystem.exists(Paths.json('pack', mod)) && !modNames.contains(mod)) {
                    var data:PackData = Json.parse(Assets.load(TEXT, Paths.json('pack', mod)));
                    modNames.push(mod);
                    availableMods[mod] = data;
                }
            }
        }
        modNames.insert(0, Paths.fallbackMod);
        availableMods[Paths.fallbackMod] = Json.parse(Assets.load(TEXT, Paths.json('pack', Paths.fallbackMod)));
        curSelected = modNames.indexOf(Paths.currentMod);
        var data:PackData = availableMods.get(Paths.currentMod);
        if(data == null) {
            curSelected = 0;
            data = availableMods[Paths.fallbackMod];
        }

        icon = new FNFSprite(card.x + 10, card.y + 10).load(IMAGE, Paths.image("pack", false));
        icon.setGraphicSize(100);
        icon.updateHitbox();
        icon.scrollFactor.set();
        icon.antialiasing = prefs.get("Antialiasing");
        add(icon);

        title = new FlxText(icon.x + (icon.width + 20), icon.y + (icon.height / 2), 0, data.title+"\n  ");
        title.setFormat(Paths.font("funkin.ttf"), 64);
        title.scrollFactor.set();
        title.antialiasing = prefs.get("Antialiasing");
        title.y -= title.height / 4;
        add(title);

        desc = new FlxText(icon.x, icon.y + (icon.height + 10), card.width - 10, data.description+"\n   ");
        desc.setFormat(Paths.font("funkin.ttf"), 24);
        desc.scrollFactor.set();
        desc.antialiasing = prefs.get("Antialiasing");
        add(desc);

        @:privateAccess
        var warn = new FlxText(card.x + (card.width - 10), card.y + (card.height - 10), "Press "+FlxKey.toStringMap[controls.list["ACCEPT"][0]]+" or "+FlxKey.toStringMap[controls.list["ACCEPT"][1]]+" to select this mod.\nPress "+FlxKey.toStringMap[controls.list["BACK"][0]]+" or "+FlxKey.toStringMap[controls.list["BACK"][1]]+" to cancel and exit this menu.\n   ");
        warn.setFormat(Paths.font("funkin.ttf"), 18, FlxColor.WHITE, RIGHT);
        warn.scrollFactor.set();
        warn.antialiasing = prefs.get("Antialiasing");
        warn.x -= warn.width + 10;
        warn.y -= warn.height - 10;
        add(warn);

        var unsafeWarnTextBS:String = !prefs.get("Allow Unsafe Mods") ? "This mod contains unsafe scripts and can\'t be selected!\nEnable \"Allow Unsafe Mods\" in Options to select.\n  " : "This mod contains unsafe scripts!\nSelect with caution!\n  ";
        unsafeText = new FlxText(icon.x, card.y + (card.height - 10), unsafeWarnTextBS);
        unsafeText.setFormat(Paths.font("funkin.ttf"), 18, FlxColor.WHITE, LEFT);
        unsafeText.scrollFactor.set();
        unsafeText.antialiasing = prefs.get("Antialiasing");
        unsafeText.visible = data.allowUnsafeScripts;
        unsafeText.y -= unsafeText.height - 10;
        add(unsafeText);

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
        selectedText.antialiasing = prefs.get("Antialiasing");
        selectedText.screenCenter(X);
        add(selectedText);

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        selectedText.text = (curSelected+1)+"/"+modNames.length;
        selectedText.screenCenter(X);

        if(controls.getP("UI_LEFT"))
            changeSelection(-1);

        if(controls.getP("UI_RIGHT"))
            changeSelection(1);

        if(controls.getP("BACK")) {
            Paths.currentMod = initialMod;
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/cancelMenu")));
            close();
        }
        if(controls.getP("ACCEPT")) {
            var canAccept:Bool = (prefs.get("Allow Unsafe Mods") && (availableMods[Paths.currentMod].allowUnsafeScripts || !availableMods[Paths.currentMod].allowUnsafeScripts)) || (!prefs.get("Allow Unsafe Mods") && !availableMods[Paths.currentMod].allowUnsafeScripts);
            if(canAccept) {
                FlxG.sound.music.stop();
                FlxG.save.data.currentMod = Paths.currentMod;
                FlxG.save.flush();
                ModData.allowUnsafeScripts = availableMods[Paths.currentMod].allowUnsafeScripts;
                FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
                FlxG.resetState();
            }
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

        title.text = data.title+"\n  ";
        desc.text = data.description+"\n  ";

        unsafeText.visible = data.allowUnsafeScripts;

        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
    }
}