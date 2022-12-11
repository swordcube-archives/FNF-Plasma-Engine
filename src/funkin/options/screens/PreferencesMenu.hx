package funkin.options.screens;

import funkin.scripting.Script;
import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;

class PreferencesMenu extends OptionScreen {
    override function create() {
        script = Script.load(Paths.script('data/substates/options/PreferencesMenu'));
		script.setParent(this);
		script.run();
        categories = [
            "Game Settings",
            "Meta Settings"
        ];
        script.call("onAddCategories");
        options = [
            "Game Settings" => [
                new BoolOption(
                    "Downscroll",
                    "Makes your notes scroll down instead of up, like they're falling.",
                    null
                ),
                new BoolOption(
                    "Centered Notes",
                    "Makes your notes centered and hides your opponent's notes.",
                    null
                ),
                new BoolOption(
                    "Ghost Tapping",
                    "Makes your notes centered and hides your opponent's notes.",
                    null
                ),
                new BoolOption(
                    "Allow Unsafe Mods",
                    "Allows mods with potentially unsafe scripts to be selected.\nKeep in mind the mod could just have fancy effects and no actual harm.",
                    null
                ),
                new NumberOption(
                    "Note Offset",
                    "Change how early or late notes spawn. Useful if you have headphones with audio delay.",
                    null,
                    5,
                    0,
                    [-1000, 1000]
                ),
            ],
            "Meta Settings" => [
                new NumberOption(
                    "Framerate Cap",
                    "Adjust how high your framerate is allowed to go.",
                    null,
                    5,
                    0,
                    [30, 1000],
                    function(value:Float) {
                        FlxG.stage.frameRate = value;
                    }
                ),
                new BoolOption(
                    "FPS Counter",
                    "Shows your FPS at the top left of the screen.",
                    null
                ),
                new BoolOption(
                    "Memory Counter",
                    "Shows your memory usage at the top left of the screen.",
                    null
                ),
                new BoolOption(
                    "Version Display",
                    "Displays your version of the game at the top left of the screen.",
                    null
                ),
                new BoolOption(
                    "Auto Pause",
                    "Change whether or not the game auto pauses when unfocusing the window.",
                    null,
                    function(value:Bool) {
                        FlxG.autoPause = value;
                    }
                ),
            ],
        ];
        script.call("onAddOptions");
        super.create();
        script.createPostCall();
    }

    override function update(elapsed:Float) {
        script.updateCall(elapsed);
        super.update(elapsed);
        script.updatePostCall(elapsed);
    }
}