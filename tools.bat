@echo off

echo UTILITY
echo MADE BY XZY
echo \n

if %1%==compile goto compile
if %1%==test goto test

:close
echo press the red x now
pause
goto close

:compile
echo Compile
echo \n
echo Debug Is %2% (y= yes n= no)
echo \n
if %2%==y lime test windows -debug
if %2%==n lime test windows

goto close




:test
echo TEST TES TEST
echo AMONG US






