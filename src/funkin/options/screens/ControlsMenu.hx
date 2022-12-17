package funkin.options.screens;

import funkin.options.types.MenuOption;
import funkin.scripting.Script;
import flixel.input.keyboard.FlxKey;
import funkin.game.Note;
import funkin.options.types.GeneralControl;

class ControlsMenu extends OptionScreen {
    public var changingBind:Bool = false;

    override function create() {
        script = Script.load(Paths.script('data/substates/options/ControlsMenu'));
		script.setParent(this);
		script.run();
        categories = [
            "Gameplay",
            "UI"
        ];
        options = [
            "Gameplay" => [
                new MenuOption(
                    "Change Gameplay Binds",
                    "Change your keybinds for gameplay.",
                    GameplayBindsMenu,
                    []
                )
            ],
            "UI" => [
                new GeneralControl(
                    "Up",
                    "UI_UP"
                ),
                new GeneralControl(
                    "Down",
                    "UI_DOWN"
                ),
                new GeneralControl(
                    "Left",
                    "UI_LEFT"
                ),
                new GeneralControl(
                    "Right",
                    "UI_RIGHT"
                ),
                new GeneralControl(
                    "Pause",
                    "PAUSE"
                ),
                new GeneralControl(
                    "Back",
                    "BACK"
                ),
                new GeneralControl(
                    "Accept",
                    "ACCEPT"
                ),
            ]
        ];

        super.create();
        descBox.visible = false;
        descText.visible = false;
        descBox.kill();
        descText.kill();
        script.createPostCall();
    }

    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);

        if(changingBind && FlxG.keys.justPressed.ANY) {
            var curKey:FlxKey = FlxG.keys.getIsDown()[0].ID;
            switch(Type.getClass(generalOptions[curSelected])) {
                case GeneralControl:
                    var option:GeneralControl = cast generalOptions[curSelected];
                    controls.list[option.saveData][bindSelected] = curKey;
            }
            canInteract = true;
            changingBind = false;
            var val = controlTextMap[curSelected];
            if(val != null) {
                val[bindSelected].text = CoolUtil.keyToString(curKey);
                val[bindSelected].visible = true;
            }
            FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/confirmMenu")));
        } else {
            if(controls.getP("ACCEPT")) {
                var option:Dynamic = generalOptions[curSelected];
                switch(Type.getClass(option)) {
                    case GeneralControl:
                        canInteract = false;
                        changingBind = true;
                        var val = controlTextMap[curSelected];
                        if(val != null) {
                            val[bindSelected].visible = false;
                        }
                        FlxG.sound.play(Assets.load(SOUND, Paths.sound("menus/scrollMenu")));
                }
            }
        }
        script.updatePostCall(elapsed);
    }
}