@echo off

echo tools
echo made by zxy xdddd
echo argrgrs are [%1%,Args To Toool:{%2%}]

if %1%==compile goto compile
if %1%==test goto test

:close
echo press the red x now
pause
goto close

:compile
echo made so i can compile quicker without vscode (rip vscode)
echo args are [debug=%2%,not needed]
if %2%==y lime test windows -debug
if %2%==n lime test windows

goto close




:test
echo TEST TES TEST
echo AMONG US






