package ui;

import flixel.FlxSprite;
import funkin.FNFSprite;

class CheckboxThingie extends FNFSprite
{
	public var daValue:Bool = false;
	public var sprTracker:FlxSprite;

	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0.0;
	public var offsetY:Float = 0.0;

	override public function new(x:Float, y:Float, state:Bool = false)
	{
		super(x, y);
		frames = GenesisAssets.getAsset('ui/checkbox', SPARROW);
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

        addOffset('checked', 17, 70);
        addOffset('static');

		antialiasing = Init.getOption('anti-aliasing');
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		daValue = state;
		refreshAnim(state);
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if(sprTracker != null)
        {
            if(copyAlpha)
                alpha = sprTracker.alpha;
            
            setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
        }
    }

    public function refreshAnim(state:Bool = false)
    {
        if(state)
            playAnim('checked', true);
        else
            playAnim('static', true);
    }
}