package funkin.ui;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

@:dox(hide)
class LogsOverlay extends Sprite {
    var titleText:TextField;
    var info:TextField;

    public function new() {
        super();

        titleText = new TextField();
        titleText.autoSize = LEFT;
        titleText.selectable = false;
        titleText.textColor = 0xFFFFFFFF;
        titleText.defaultTextFormat = new TextFormat(Paths.font("pixel.otf"), 16);
        titleText.text = 'Plasma Engine Logs | ${Main.engineVersion}';

        info = new TextField();
        info.autoSize = LEFT;
        info.selectable = false;
        info.textColor = 0xFFFFFF;
        info.alpha = 0.5;
        info.y = 20;
        info.defaultTextFormat = new TextFormat(Paths.font("pixel.otf"), 12);
        info.text = "[F5] Close | [F6] Clear";

        addChild(titleText);
        addChild(info);
        
        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
            switch(e.keyCode) {
                case Keyboard.F5: visible = !visible;
            }
        });

        visible = false;
    }

    override function __enterFrame(deltaTime:Int) { // basically an Update Function
        super.__enterFrame(deltaTime);
        
        graphics.clear();
        graphics.beginFill(0x000000, 0.5);
        graphics.drawRect(0, 0, lime.app.Application.current.window.width, lime.app.Application.current.window.height);
        graphics.endFill();

        titleText.x = (lime.app.Application.current.window.width - titleText.width) / 2;
        info.x = (lime.app.Application.current.window.width - info.width) / 2;
    }
}