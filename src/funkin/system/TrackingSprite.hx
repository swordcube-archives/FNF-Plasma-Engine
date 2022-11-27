package funkin.system;

/**
 * A sprite that tracks another sprite with customizable offsets.
 * @author Leather128
 */
 // i can't be bothered to write this shit myself lmao
 class TrackingSprite extends FNFSprite {
    /**
     * Whether or not to copy the alpha of the sprite we are tracking
     */
    public var copyAlpha:Bool = true;

    // leather you misspelt offset here lmao!
    /**
     * The offset in X and Y to the tracked object.
     */
    public var trackingOffset:flixel.math.FlxPoint = new flixel.math.FlxPoint(10.0, -30.0);

    /**
     * The object / sprite we are tracking.
     */
    public var tracked:flixel.FlxSprite;

    /**
     * Tracking mode (or direction) of this sprite.
     */
    public var trackingMode:TrackingMode = RIGHT;

    override function update(elapsed:Float):Void {
        // tracking modes
        if (tracked != null) {
            switch (trackingMode) {
                case RIGHT: setPosition(tracked.x + tracked.width + trackingOffset.x, tracked.y + trackingOffset.y);
                case LEFT: setPosition(tracked.x + trackingOffset.x, tracked.y + trackingOffset.y);
                case UP: setPosition(tracked.x + (tracked.width / 2.0) + trackingOffset.x, tracked.y - height + trackingOffset.y);
                case DOWN: setPosition(tracked.x + (tracked.width / 2.0) + trackingOffset.x, tracked.y + tracked.height + trackingOffset.y);
            }
            if(copyAlpha) alpha = tracked.alpha;
        }

        super.update(elapsed);
    }

    override public function load(type:base.AssetType, path:String):TrackingSprite {
        return cast super.load(type, path);
    }
}

/**
 * Enum to store the mode (or direction) that a tracking sprite tracks.
 */
enum TrackingMode {
    RIGHT;
    LEFT;
    UP;
    DOWN;
}