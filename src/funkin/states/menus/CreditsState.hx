package funkin.states.menus;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import funkin.github.GitHub;
import funkin.system.FNFSprite;

typedef CreditData = {
    var username:String;
    var description:Null<String>;
    var avatar:Null<FlxGraphic>;
}

class CreditsState extends FNFState {
    public static var repoOwner:String = "swordcube";
    public static var repoName:String = "FNF-Plasma-Engine";

    var credits:Array<CreditData> = [];
    var specialCredits:Map<String, CreditData> = [
        "swordcube" => {
            username: null,
            description: "The original creator of the engine.\nFeel free to send any feedback or feature ideas on my discord!: ✦ swordcube ✦#8167",
            avatar: null
        }
    ];

    override function create() {
        super.create();

        enableTransitions();

        var bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGBlue"));
        bg.scrollFactor.set();
        add(bg);

        var contributors = GitHub.getContributors(repoOwner, repoName, function(e) {
            Console.error(e);
        });

        for(contributor in contributors) {
            var bytes = GitHub.__requestBytesOnGitHubServers('${contributor.avatar_url}&size=256');
            var bmp = BitmapData.fromBytes(bytes);
            credits.push({
                username: contributor.login,
                description: "This user has contributed to the repository by updating the readme/documentation or adding, removing or fixing features.",
                avatar: FlxG.bitmap.add(bmp, false, 'GITHUB-USER:${contributor.login}')
            });
        }

        for(i in 0...credits.length) {
            var credit:CreditData = credits[i];
            if(specialCredits.exists(credit.username)) {
                var special:CreditData = specialCredits[credit.username];
                if(special.username != null)
                    credits[i].username = special.username;

                if(special.description != null)
                    credits[i].description = special.description;

                if(special.avatar != null)
                    credits[i].avatar = special.avatar;
            } else continue;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.getP("BACK")) {
            CoolUtil.playMenuSFX(2);
            FlxG.switchState(new funkin.states.menus.MainMenuState());
        }
    }
}