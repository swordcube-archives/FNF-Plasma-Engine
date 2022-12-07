package funkin.options.screens;

import funkin.scripting.events.SubStateCreationEvent;
import funkin.scripting.Script;
import flixel.FlxSprite;
import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;
import funkin.options.types.ListOption;

class AppearanceMenu extends OptionScreen {
    override function create() {
        script = Script.load(Paths.script('data/substates/options/AppearanceMenu'));
		script.setParent(this);
		script.run(false);
		script.event("onSubStateCreation", new SubStateCreationEvent(this));
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
                new BoolOption(
                    "Enable Note Splashes",
                    "Choose whether you want note splashes on or not, Useful if you find these distracting.",
                    null
                ),
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
            ]
        ];
        script.call("onAddOptions");
        super.create();
        script.event("onSubStateCreationPost", new SubStateCreationEvent(this));
    }

    override function update(elapsed:Float) {
        for(func in ["onUpdate", "update"]) script.call(func, [elapsed]);
        super.update(elapsed);
        for(func in ["onUpdate", "update"]) script.call(func+"Post", [elapsed]);
    }
}