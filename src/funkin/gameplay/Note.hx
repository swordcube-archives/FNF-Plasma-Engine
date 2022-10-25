package funkin.gameplay;

typedef NoteInfo = {
    var directions:Array<String>;
    var colors:Array<Array<Int>>;
    var scale:Float;
    var spacing:Float;
}

class Note extends Sprite {
    public static final spacing:Float = 160 * 0.7;
    public static final keyInfo:Map<Int, NoteInfo> = [
        1  => {
            directions: ["space"],
            colors: [[0, -100, 0]],
            scale: 1,
            spacing: 1
        },
        2  => {
            directions: ["left", "right"],
            colors: [[194, 75, 153], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
        3  => {
            directions: ["left", "space", "right"],
            colors: [[194, 75, 153], [204, 204, 204], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
        4  => {
            directions: ["left", "down", "up", "right"],
            colors: [[194, 75, 153], [0, 255, 255], [18, 250, 5], [249, 57, 63]],
            scale: 1,
            spacing: 1
        },
    ];
}