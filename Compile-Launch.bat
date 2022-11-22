echo Starting Compile...
lime build windows
@echo off
set /p menu="Did it Compile the Correct Way? [Y/N]"
       if %menu%==Y goto Launch
       if %menu%==y goto Launch
       if %menu%==N goto ReadMoment
       if %menu%==n goto ReadMoment
@echo on

:Launch
cd export\release\windows\bin
cls
echo Down Below is logs of le game
PlasmaEngine
cd ..
cd ..
cd ..
cd ..
goto ReadMoment

:ReadMoment
pause