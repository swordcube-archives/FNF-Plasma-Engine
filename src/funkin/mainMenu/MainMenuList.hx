package funkin.mainMenu;

import funkin.states.MainMenu;
import flixel.group.FlxGroup.FlxTypedGroup;

class MainMenuList extends FlxTypedGroup<MainMenuItem> {
    public var list:Array<String> = [];
    public var enabled:Bool = true;

    public function addItem(name:String, callback:Void->Void) {
        list.push(name);
        var button:MainMenuItem = new MainMenuItem(0, 70 + (150 * members.length));
        button.load(SPARROW, Paths.image('menus/main/$name'));
        button.addAnim("idle", "basic", 24, true);
        button.addAnim("selected", "white", 24, true);
        button.playAnim("idle");
        button.screenCenter(X);
        button.ID = members.length;
        button.callback = function() {
            Console.debug("SWITCHING TO MENU: "+name);
            callback();
        };
        button.scrollFactor.set();
        add(button);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(Controls.getP("accept") && enabled)
            members[MainMenu.curSelected].callback();
    }
}