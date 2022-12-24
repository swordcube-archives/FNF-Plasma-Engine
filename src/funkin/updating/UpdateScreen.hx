package funkin.updating;

#if !docs
import funkin.system.FNFSprite;
import funkin.ui.FunkinText;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import funkin.states.FNFState;
import funkin.states.menus.TitleState;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxBar;
import funkin.updating.UpdateUtil.UpdateCheckCallback;

class UpdateScreen extends FNFState {
    var chosenColor:Int = 0;
    var rainbowList:Array<FlxColor> = [
        0xFFFF0000,
        0xFFFF7300,
        0xFFFFFB00,
        0xFF33FF00,
        0xFF00FFD5,
        0xFF006EFF,
        0xFF2F00FF,
        0xFFA200FF,
        0xFFFF00C8
    ];

    public var updater:AsyncUpdater;
    public var progressBar:FlxBar;

    public var rainbowGradient:FlxSprite;

    public var done:Bool = false;
    public var lerpSpeed:Float = 0;

    public var generalProgress:FunkinText;
    public var partProgress:FunkinText;

    public var logo:FNFSprite;

    public var overSound:FlxSound;

    public function new(check:UpdateCheckCallback) {
        super();
        updater = new AsyncUpdater(check.updates);
    }

    override function create() {
        super.create();

        rainbowGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.TRANSPARENT, 0xFFFFFFFF]);
        rainbowGradient.y += rainbowGradient.height * 0.5;
        rainbowGradient.color = rainbowList.last();
        add(rainbowGradient);

        dumbassTween();

        logo = new FNFSprite(0, 10).load("SPARROW", Paths.image("menus/title/logoBumpin"));
        logo.animation.addByPrefix("idle", "logo bumpin", 24, false);
        logo.animation.play("idle");
        logo.scale.set(0.8, 0.8);
        logo.updateHitbox();
        logo.screenCenter(X);
        add(logo);

        progressBar = new FlxBar(0, FlxG.height - 75, LEFT_TO_RIGHT, FlxG.width - 25, 45);
        progressBar.createFilledBar(0xFFFFFFFF, 0xFF6E6E6E);
        progressBar.setRange(0, 4);
        add(progressBar);

        partProgress = new FunkinText(0, progressBar.y, FlxG.width, "-\n-", 20);
        partProgress.y -= partProgress.height;
        partProgress.alignment = CENTER;
        add(partProgress);

        generalProgress = new FunkinText(0, partProgress.y - 10, FlxG.width, "", 32);
        generalProgress.y -= generalProgress.height;
        generalProgress.alignment = CENTER;
        add(generalProgress);

        overSound = FlxG.sound.load(Assets.load(SOUND, Paths.sound('gameOverEnd')));

        Conductor.onBeat.add(beatHit);

        updater.execute();
    }

    function beatHit(beat:Int) {
        if(done) return;

        logo.animation.play("idle", true);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(FlxG.sound.music != null && FlxG.sound.music.playing)
            Conductor.position = FlxG.sound.music.time;

        if (done) return;

        var prog = updater.progress;
        lerpSpeed = MathUtil.fixedLerp(lerpSpeed, prog.downloadSpeed, 1/16);

        switch(prog.step) {
            case PREPARING:
                progressBar.value = 0;
                generalProgress.text = "Preparing update installation... (1/4)";
                partProgress.text = "Creating installation folder and cleaning old update files...";

            case DOWNLOADING_ASSETS:
                progressBar.value = 1 + ((prog.curFile-1+(prog.bytesLoaded/prog.bytesTotal)) / prog.files);
                generalProgress.text = "Downloading update assets... (2/4)";
                partProgress.text = 'Downloading file ${prog.curFileName}\n(${prog.curFile+1}/${prog.files} | ${CoolUtil.getSizeLabel(prog.bytesLoaded)} / ${CoolUtil.getSizeLabel(prog.bytesTotal)} | ${CoolUtil.getSizeLabel(lerpSpeed)}/s)';

            case DOWNLOADING_EXECUTABLE:
                progressBar.value = 2 + (prog.bytesLoaded/prog.bytesTotal);
                generalProgress.text = "Downloading new engine executable... (3/4)";
                partProgress.text = 'Downloading ${prog.curFileName}\n(${CoolUtil.getSizeLabel(prog.bytesLoaded)} / ${CoolUtil.getSizeLabel(prog.bytesTotal)} | ${CoolUtil.getSizeLabel(lerpSpeed)}/s)';

            case INSTALLING:
                progressBar.value = 3 + ((prog.curFile-1+(prog.curZipProgress.curFile/prog.curZipProgress.fileCount))/prog.files);
                generalProgress.text = "Installing new files... (4/4)";
                partProgress.text = 'Installing ${prog.curFileName}\n(${prog.curFile}/${prog.files})';
        }

        if (done = prog.done) {
            // update is done, play bf's anim
            FlxG.sound.music.stop();
            overSound.play();
            
            remove(generalProgress);
            remove(partProgress);
            generalProgress.destroy();
            partProgress.destroy();

            FlxG.camera.fade(0xFF000000, overSound.length / 1000, false, function() {
                if (updater.executableReplaced) {
                    // the executable has been replaced, restart the game entirely
                    #if windows
                    Sys.command('start /B ${AsyncUpdater.executableName}');
                    #else
                    // We have to make the new executable allowed to execute
                    // before we can execute it!
                    Sys.command('chmod +x ./${AsyncUpdater.executableName} && ./${AsyncUpdater.executableName}');
                    #end
                    openfl.system.System.exit(0);
                } else {
                    // assets update, switch back to TitleState.
                    FlxG.switchState(new TitleState());
                }
            });
        }
    }

    function dumbassTween() {
        FlxTween.color(rainbowGradient, 2.5, rainbowGradient.color, rainbowList[chosenColor], {onComplete: function(twn:FlxTween) {
            dumbassTween(); // recursion!!!
        }});
        chosenColor = FlxMath.wrap(chosenColor+1, 0, rainbowList.length-1);
    }
}
#end