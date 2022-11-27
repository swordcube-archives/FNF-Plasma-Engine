@echo off
lime build windows -debug -livereload
cd export\debug\windows\bin\
.\PlasmaEngine.exe -updatebuild -livereload
cd ../../../../