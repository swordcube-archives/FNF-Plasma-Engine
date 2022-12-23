package funkin.options.screens;

import funkin.options.types.MenuOption;
import funkin.scripting.Script;
import flixel.FlxSprite;
import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;
import funkin.options.types.ListOption;

class AppearanceMenu extends OptionScreen {
    override function create() {
        script = Script.load(Paths.script('data/substates/options/AppearanceMenu'));
		script.setParent(this);
		script.run();
        categories = [
            "Judgements",
            "Notes",
            "Accessibility"
        ];
        script.call("onAddCategories");
        options = [
            "Judgements" => [
                new ListOption(
                    "Camera",
                    "Change what camera the judgements are on.",
                    "Judgement Camera",
                    ["World", "HUD"]
                ),
                new ListOption(
                    "Counter",
                    "Choose whether you want somewhere to display your judgements (Sicks, Goods, etc) and where you want them.",
                    "Judgement Counter",
                    ["None", "Left", "Right"]
                ),
            ],
            "Notes" => [
                new ListOption(
                    "Sustain Layer",
                    "Choose how you want sustains to be layered on the strumline.",
                    "Sustain Layering",
                    ["Behind", "Above"]
                ),
                new ListOption(
                    "Note Skin",
                    "Choose what skin you want to use for your notes.",
                    null,
                    ["Arrows", "Circles"]
                ),
                new NumberOption(
                    "Lane Underlay",
                    "Choose whether or not you want a box to go behind your notes. Helps with readability in charts.\n0 = OFF, 0.5 = Half Visible, 1 = ON",
                    null,
                    0.1,
                    1,
                    [0, 1]
                ),
                new BoolOption(
                    "Enable Note Splashes",
                    "Choose whether you want note splashes on or not, Useful if you find these distracting.",
                    null
                ),
                new MenuOption(
                    "Adjust Note Colors",
                    "Change the colors of your notes during gameplay.",
                    NoteColoringMenu,
                    []
                )
            ],
            "Accessibility" => [
                new BoolOption(
                    "Flashing Lights",
                    "Enables flashing lights. Turn this off if you are epileptic or are sensitive to flashing lights.\n(WARNING: May not work on every mod!!)",
                    null
                ),
                new BoolOption(
                    "Enable Antialiasing",
                    "Choose whether or not to enable Antialiasing. Helps performance on low-end PCs.",
                    "Antialiasing",
                    function(value:Bool) {
                        FlxSprite.defaultAntialiasing = value;
                    }
                ),
                new BoolOption(
                    "Fancy Console",
                    "Choose whether or not the console should have emojis and color.\nUseful for terminals that don't support emoji or color.",
                    null,
                    function(value:Bool) {
                        Console.fancyText = value;
                    }
                )
            ]
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