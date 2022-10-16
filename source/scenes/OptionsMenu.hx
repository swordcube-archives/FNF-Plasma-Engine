package scenes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.Alphabet;
import misc.DiscordRPC;
import openfl.media.Sound;
import scenes.options.ControlsMenu;
import scenes.options.NoteColorsMenu;
import scenes.options.OptionsPage;

typedef SceneInfo = {
    var scene:Class<Scene>;
    @:optional var sceneName:String; // Used for ScriptedScene!!
    @:optional var args:Array<Any>;
}

class OptionsMenu extends Scene {
    public static var sceneInfo:SceneInfo = {
        scene: ScriptedScene,
        sceneName: "MainMenu"
    };
    var curSelected:Int = 0;
    var grpAlphabet:FlxTypedSpriteGroup<Alphabet>;

    var pages:Array<PageData> = Settings.defaultPages.copy();

    var loadedSFX:Map<String, Sound> = [
        "scrollMenu"   => Assets.get(SOUND, Paths.sound("menus/scrollMenu")),
        "cancelMenu"   => Assets.get(SOUND, Paths.sound("menus/cancelMenu"))
    ];

    public function new() {
        super();
        sceneInfo = {
            scene: ScriptedScene,
            sceneName: "MainMenu"
        };
    }

    override function start() {
        var bg:Sprite = new Sprite().load(IMAGE, Paths.image("menuBGDesat"));
        bg.color = 0xFFEA71FD;
        add(bg);

        grpAlphabet = new FlxTypedSpriteGroup<Alphabet>();
        add(grpAlphabet);

        pages.push({
            title: "Exit",
            desc: "Exits the options menu."
        });
        for(i in 0...pages.length) {
            var p = pages[i];
            var a:Alphabet = new Alphabet(0, 100 + (100 * grpAlphabet.length), p.title, true);
            a.alpha = curSelected == i ? 1 : 0.6;
            a.screenCenter(X);
            grpAlphabet.add(a);
        }

        changeSelection();
    }

    override function process(delta:Float) {
        if(Controls.UI_UP_P)
            changeSelection(-1);

        if(Controls.UI_DOWN_P)
            changeSelection(1);

        if(Controls.BACK_P)
            goBack();

        if(Controls.ACCEPT_P) {
            switch(pages[curSelected].title) {
                case "Note Colors":
                    openSubState(new NoteColorsMenu());
                case "Controls":
                    openSubState(new ControlsMenu());
                case "Exit":
                    goBack();
                default:
                    var settingsList:Array<SettingData> = [];
                    for(s in Settings.defaultSettings) {
                        if(s.page == pages[curSelected].title)
                            settingsList.push(s);
                    }
                    openSubState(new OptionsPage(settingsList));
            }
        }
    }

    function goBack() {
        Settings.save();
        FlxG.sound.play(loadedSFX["cancelMenu"]);
        if(sceneInfo.args == null) sceneInfo.args = [];
        if(sceneInfo.scene == ScriptedScene)
            Main.switchScene(new ScriptedScene(sceneInfo.sceneName, sceneInfo.args));
        else
            Main.switchScene(Type.createInstance(sceneInfo.scene, sceneInfo.args));
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if(curSelected < 0)
            curSelected = grpAlphabet.length-1;
        if(curSelected > grpAlphabet.length-1)
            curSelected = 0;

        for(i in 0...grpAlphabet.members.length)
            grpAlphabet.members[i].alpha = curSelected == i ? 1 : 0.6;

        DiscordRPC.changePresence(
            "In the Options Menu",
            "Selecting "+pages[curSelected]
        );

        FlxG.sound.play(loadedSFX["scrollMenu"]);
    }
}