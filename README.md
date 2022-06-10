# 🎮 Genesis Engine

An FNF engine designed to be lightweight and easy to mod.

You can use `.hx` files to make modcharts, stages, custom UI's, and more!
Soon you ***might*** be able to use `.hx` files to customize existing menus and make custom states!

# 🖥️ Building the game

Step 1. [Install git-scm](https://git-scm.com/downloads) if you don't have it already.

Step 2. [Install Haxe](https://haxe.org/download/)

Step 3. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)

Step 4. Run these commands to install the libraries required:
```
haxelib install flixel
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git openfl https://github.com/openfl/openfl
```

Step 5 (Windows only). Install Visual Studio Community 2019, and while installing instead of selecting the normal options, only select these components in the 'individual components' instead (or things named very similar)
```
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
```

Step 6. Run `lime test [operating system goes here]` in the project directory while replacing '[operating system goes here]' with your build type (usually `windows`, `linux`, `mac`, etc).
