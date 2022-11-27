package funkin.ui;

import funkin.system.TrackingSprite;

class UIArrow extends TrackingSprite {
    public var onJustPressed:Void->Void;
    public var onJustReleased:Void->Void;

    public var control:String = "UI_LEFT";

    public function new(x:Float = 0, y:Float = 0, right:Bool = false) {
        super(x, y);
        load(SPARROW, Paths.image("ui/storyUI"));
        addAnim("idle", "arrow "+(right ? "right" : "left"));
        addAnim("press", "arrow push "+(right ? "right" : "left"));
        playAnim("idle");

        onJustPressed = function() {
            playAnim("press");
        };
        onJustReleased = function() {
            playAnim("idle");
        };
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var controls = PlayerSettings.controls;
        if(controls.getP(control)) onJustPressed();
        if(controls.getR(control)) onJustReleased();
    }
}