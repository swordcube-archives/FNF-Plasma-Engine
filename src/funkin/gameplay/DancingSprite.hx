package funkin.gameplay;

/**
 * A sprite that can dance left or right.
 */
class DancingSprite extends Sprite {
    var danceDir:Bool = false;
    public function dance() {
        danceDir = !danceDir;
        playAnim(danceDir ? 'danceRight' : 'danceLeft', true);
    }

    override public function load(type:base.assets.AssetType, path:String):DancingSprite {
        return cast super.load(type, path);
    }
}