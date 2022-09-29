echo OFF
:build
echo Running "lime test windows -dce no %*"
echo When it asks you to setup the command for lime, type "y %*"!
echo And make sure to remove openfl 9.2.0 when this is done via "haxelib remove openfl 9.2.0 %*"
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
haxelib git hscript-improved https://github.com/YoshiCrafter29/hscript-improved
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons
haxelib git flixel-ui https://github.com/HaxeFlixel/flixel-ui
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git openfl https://github.com/openfl/openfl
lime test windows -dce no %*
pause
goto build