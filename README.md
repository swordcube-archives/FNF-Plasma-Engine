# 🎮 Plasma Engine
A Friday Night Funkin' engine designed to be lightweight and easy to mod. Use `.hx` files to make modcharts, stages, characters, states, and more!

### ⚠️ HEY!! If you want to see more progress on Plasma, go to the `dev` branch. It's where i'm working on things most often. ⚠️
I only update this branch when a full release is ready. (pre-releases don't count)
So yeah go there to see some cool progress!!!
________________________________________________________________________________________________________________________________

### Here's a **Windows** debug build so you can see more of your HScript errors:

[link (real)](https://drive.google.com/file/d/10mho5g__RmmdnCnU6JnTcA6jPDAXL95e/view?usp=sharing)

________________________________________________________________________________________________________________________________

# 🖥️ Building the game
- Step 1. [Install git-scm](https://git-scm.com/downloads) if you don't have it already.
- Step 2. [Install Haxe](https://haxe.org/download/)
- Step 3. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/)
- Step 4. Run these commands to install required libraries:
```
haxelib git flixel https://github.com/YoshiCrafter29/flixel
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec
haxelib git hscript-improved https://github.com/YoshiCrafter29/hscript-improved
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git openfl https://github.com/openfl/openfl
```
- Step 5. If you run on Windows, install [Visual Studio Community 2019](https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=community&rel=16&utm_medium=microsoft&utm_source=docs.microsoft.com&utm_campaign=download+from+relnotes&utm_content=vs2019ga+button) using these specific components in `Individual Components` instead of selecting the normal options:
```
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
```
- Step 6. Run `lime test <windows/linux/mac>`, choosing your OS. (Ex. `lime test windows`)
