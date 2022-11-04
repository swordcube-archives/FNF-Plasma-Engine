package funkin.states.options;

// Pages
import funkin.states.options.pages.PreferencesMenu;
import funkin.states.options.pages.AppearanceMenu;
import funkin.states.options.pages.ControlsMenu;
// Misc
import openfl.media.Sound;

class OptionsMenu extends FunkinState {
    public var pages:SelectablePageGroup;
    public var curSelected:Int = 0;

    var cachedSounds:Map<String, Sound> = [
		"scroll"  => Assets.load(SOUND, Paths.sound("menus/scrollMenu")),
		"cancel"  => Assets.load(SOUND, Paths.sound("menus/cancelMenu")),
		"confirm" => Assets.load(SOUND, Paths.sound("menus/confirmMenu")),
	];

    override function create() {
        super.create();

        DiscordRPC.changePresence(
            "In the Options Menu",
            null
        );

        var bg = new Sprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
        bg.color = 0xFFEA71FD;
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

        pages = new SelectablePageGroup();
        add(pages);

        // Add pages here!
        pages.addPage("Preferences", function() {
            openSubState(new PreferencesMenu());
        });
        pages.addPage("Appearance", function() {
            openSubState(new AppearanceMenu());
        });
        pages.addPage("Controls", function() {
            openSubState(new ControlsMenu());
        });
        pages.addPage("Mod Settings", function() {
            Console.info("NON FUNCTIONAL!");
        });
        pages.addPage("Exit", exit);

        // Update the text
        changeSelection();
    }

    public function exit() {
        Main.switchState(new MainMenu());
    }

    function changeSelection(change:Int = 0) {
        if(!pages.enabled) return;
        curSelected += change;
        if(curSelected < 0) curSelected = pages.length - 1;
        if(curSelected > pages.length - 1) curSelected = 0;

        for(i in 0...pages.length) {
            var page:SelectablePage = pages.members[i];
            page.alpha = curSelected == i ? 1 : 0.6;
        }
        FlxG.sound.play(cachedSounds["scroll"]);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Controls.getP("ui_up")) changeSelection(-1);
        if(Controls.getP("ui_down")) changeSelection(1);
        if(Controls.getP("accept")) pages.switchPage(curSelected);

        if(Controls.getP("back")) {
            FlxG.sound.play(cachedSounds["cancel"]);
            exit();
        }
    }
}