package systems;

class ExtraKeys
{
    // the shit works like this:
    // the name of the thing in the xml
    // and the default colors (in rgb format)
    public static var arrowInfo:Array<Dynamic> = [
        [ // 1k
            ["space"],
            [[0, -100, 0]]
        ],
        [ // 2k
            ["left", "right"],
            [[194, 75, 153], [249, 57, 63]]
        ],
        [ // 3k
            ["left", "space", "right"],
            [[194, 75, 153], [255, 255, 255], [249, 57, 63]]
        ],
        [ // 4k
            ["left", "down", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63]]
        ],
        [ // 5k
            ["left", "down", "space", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [255, 255, 255], [18, 250, 5], [249, 57, 63]]
        ],
        [ // 6k
            ["left", "down", "right", "left", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [249, 57, 63], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        ],
        [ // 7k
            ["left", "down", "right", "space", "left", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [249, 57, 63], [255, 255, 255], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        ],
        [ // 8k
            ["left", "down", "up", "right", "left", "down", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        ],
        [ // 9k
            ["left", "down", "up", "right", "space", "left", "down", "up", "right"],
            [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63], [255, 255, 255], [0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
        ],
    ];
}