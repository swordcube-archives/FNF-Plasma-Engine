package funkin.updating;

#if !docs
import funkin.ui.FunkinText;
import funkin.system.FNFSprite;
import funkin.states.FNFState;
import funkin.system.MarkdownUtil;
import funkin.states.menus.MainMenuState;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import funkin.updating.UpdateUtil.UpdateCheckCallback;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import funkin.ui.Alphabet;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class UpdateAvailableScreen extends FNFState {
    public var bg:FNFSprite;
    
    public var versionCheckBG:FlxSprite;
    public var title:Alphabet;
    public var versionDifferenceLabel:FunkinText;
    public var changeLogText:FunkinText;
    public var check:UpdateCheckCallback;

    public var optionsBG:FlxSprite;
    public var installButton:FunkinText;
    public var skipButton:FunkinText;

    public var installSelected:Bool = true;

    public function new(check:UpdateCheckCallback) {
        super();
        this.check = check;
    }

    public override function create() {
        super.create();
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.mouse.visible = true;
        
        FlxG.camera.flash(0xFF000000, 0.25);

        bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGNeo"));
        bg.antialiasing = true;
        bg.scrollFactor.set();
        bg.screenCenter();
        bg.alpha = 0.3;
        add(bg);

        title = new Alphabet(0, 10, Bold, "NEW UPDATE");
        title.screenCenter(X);
        title.scrollFactor.set();

        versionDifferenceLabel = new FunkinText(0, title.y + title.height + 10, FlxG.width, '${check.currentVersionTag} < ${check.newVersionTag}', 28, false);
        versionDifferenceLabel.color = 0xFFFFFFFF;
        versionDifferenceLabel.alignment = CENTER;
        versionDifferenceLabel.scrollFactor.set();

        versionCheckBG = new FlxSprite(-1, -1).makeGraphic(1, 1, 0xFFFFFFFF);
        versionCheckBG.alpha = 0.75;
        versionCheckBG.color = 0xFF000000;
        versionCheckBG.scale.set(FlxG.width + 2, versionDifferenceLabel.y + versionDifferenceLabel.height + 14);
        versionCheckBG.updateHitbox();
        versionCheckBG.scrollFactor.set();

        changeLogText = new FunkinText(0, versionCheckBG.y + versionCheckBG.height + 10, FlxG.width, "", 20, true);
        changeLogText.borderColor = 0xFF000000;
        MarkdownUtil.applyMarkdownText(changeLogText, check.updates.last().body);

        installButton = new FunkinText(0, FlxG.height - 25, Std.int(FlxG.width / 2), "> INSTALL <", 32);
        skipButton = new FunkinText(Std.int(FlxG.width / 2), FlxG.height - 25, Std.int(FlxG.width / 2), "SKIP", 32);

        skipButton.y -= skipButton.height;
        installButton.y -= installButton.height;

        installButton.alignment = skipButton.alignment = CENTER;

        optionsBG = new FlxSprite(-1, installButton.y - 25).makeGraphic(1, 1, 0xFFFFFFFF);
        optionsBG.alpha = 0.75;
        optionsBG.color = 0xFF000000;
        optionsBG.scale.set(FlxG.width + 2, Std.int(FlxG.height - optionsBG.y));
        optionsBG.updateHitbox();

        installButton.scrollFactor.set();
        skipButton.scrollFactor.set();
        optionsBG.scrollFactor.set();
        
        add(changeLogText);

        add(versionCheckBG);
        add(title);
        add(versionDifferenceLabel);

        add(optionsBG);
        add(installButton);
        add(skipButton);

        oldPos = FlxG.mouse.getScreenPosition();
    }

    var destY:Float = 0;
    var oldPos:FlxPoint;

    public override function update(elapsed:Float) {
        super.update(elapsed);

        destY = FlxMath.bound(destY - (FlxG.mouse.wheel * 75), 0, Math.max(0, changeLogText.height - FlxG.height + versionCheckBG.height + 20 + optionsBG.height));
        FlxG.camera.scroll.y = MathUtil.fixedLerp(FlxG.camera.scroll.y, destY, 1/3);

        if (controls.getP("UI_LEFT") || controls.getP("UI_RIGHT")) {
            installSelected = !installSelected;
            changeSelection();
        }

        var newPos = FlxG.mouse.getScreenPosition();
        if (oldPos.x != newPos.x || oldPos.y != newPos.y) {
            if (newPos.y >= optionsBG.y) {
                if (installSelected != (installSelected = (newPos.x < (FlxG.width / 2)))) {
                    changeSelection();
                }
            }
            oldPos = newPos;
        }

        if (controls.getP("ACCEPT") || (newPos.y >= optionsBG.y && FlxG.mouse.justPressed))
            select();
    }

    public function select() {
        if (installSelected) {
            CoolUtil.playMenuSFX(1);
            FlxG.switchState(new UpdateScreen(check));
        } else {
            CoolUtil.playMenuSFX(2);
            FlxG.switchState(new MainMenuState());
        }
    }

    public function changeSelection() {
        CoolUtil.playMenuSFX();
        if (installSelected) {
            installButton.text = "> INSTALL <";
            skipButton.text = "SKIP";
        } else {
            installButton.text = "INSTALL";
            skipButton.text = "> SKIP <";
        }
    }

    public override function destroy() {
        super.destroy();
        FlxG.mouse.visible = false;
    }
}
#end