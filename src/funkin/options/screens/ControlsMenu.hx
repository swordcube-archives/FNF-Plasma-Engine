package funkin.options.screens;

import funkin.scripting.Script;
import flixel.input.keyboard.FlxKey;
import funkin.game.Note;
import funkin.options.types.GameplayControl;
import funkin.options.types.GeneralControl;

class ControlsMenu extends OptionScreen {
    public var changingBind:Bool = false;

    override function create() {
        script = Script.load(Paths.script('data/substates/options/ControlsMenu'));
		script.setParent(this);
		script.run();
        categories = [
            "UI"
        ];
        options = [
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

        var i = Lambda.count(Note.keyInfo);
        for(ass in 0...Lambda.count(Note.keyInfo)) {
            var categoryName:String = i+"K Bind"+(i > 1 ? "s" : "");
            categories.insert(0, categoryName);
            options[categoryName] = [];
            var keyIndex:Int = 0;
            for(key in PlayerSettings.controls.default_list["GAME_"+i]) {
                options[categoryName].push(new GameplayControl(
                    "Bind "+CoolUtil.firstLetterUppercase(Note.keyInfo[i].directions[keyIndex].toLowerCase()),
                    "GAME_"+i,
                    keyIndex
                ));
                keyIndex++;
            }
            i--;
        }
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
                case GameplayControl:
                    var option:GameplayControl = cast generalOptions[curSelected];
                    controls.list[option.saveData][option.keyIndex] = curKey;

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
                    case GameplayControl, GeneralControl:
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