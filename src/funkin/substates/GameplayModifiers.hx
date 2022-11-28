package funkin.substates;

import funkin.options.types.NumberOption;
import funkin.options.types.BoolOption;
import funkin.options.types.ListOption;
import funkin.options.screens.OptionScreen;

class GameplayModifiers extends OptionScreen {
    override function create() {
        categories = [
            "Speed Settings",
            "Misc Settings"
        ];
        options = [
            "Speed Settings" => [
                new ListOption(
                    "Scroll Type",
                    "Choose if the scroll speed is a multiplier or a constant.",
                    null,
                    ["Multiplier", "Constant"]
                ),
                new NumberOption(
                    "Scroll Speed",
                    "Change how fast your notes go.",
                    null,
                    0.1,
                    1,
                    [0, 10]
                ),
                new NumberOption(
                    "Playback Rate",
                    "Change how fast you want to play a song.",
                    null,
                    0.05,
                    2,
                    [0.5, 3.0],
                    function(value:Float) {
                        FlxG.sound.music.pitch = value;
                    }
                )
            ],
            "Misc Settings" => [
                new BoolOption(
                    "Botplay",
                    "Choose whether or not you want the game to hit every note for you.\nUseful for showcases!",
                    null
                ),
                new BoolOption(
                    "Play As Opponent",
                    "Choose whether or not you want to kick boyfriend's ass instead of the opposite.",
                    null
                )
            ]
        ];
        super.create();

        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
    }

    override public function goBack() {
        PlayerSettings.prefs.flush();
        super.goBack();
    }
}