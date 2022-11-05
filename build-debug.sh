#! /bin/sh
lime test linux -debug --haxelib=hxcpp-debug-server -livereload
cd export/debug/linux/bin/
./PlasmaEngine.exe -livereload -devmode