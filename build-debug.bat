@echo off
lime build windows -debug --haxelib=hxcpp-debug-server -livereload
cd export/debug/windows/bin/
.\PlasmaEngine.exe -livereload -devmode