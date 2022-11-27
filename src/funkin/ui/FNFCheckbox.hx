package funkin.ui;

import funkin.system.TrackingSprite;

class FNFCheckbox extends TrackingSprite {
    public var checked(default, set):Bool = false;

    function set_checked(v:Bool):Bool {
        playAnim(v ? "on" : "off");
		return checked = v;
	}

    public function new(x:Float, y:Float, checked:Bool = false) {
        super(x, y);

        frames = Assets.load(SPARROW, Paths.image("ui/checkbox"));

        addAnim("on", "on0", 24, false);
        addAnim("on-S", "on static0", 24, false);

        addAnim("off", "off0", 24, false);
        addAnim("off-S", "off static0", 24, false);

        scale.set(1.2, 1.2);
        updateHitbox();

        this.checked = checked;
        playAnim(checked ? "on-S" : "off-S");
    }
}