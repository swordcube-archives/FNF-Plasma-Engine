echo OFF
:build
echo Running "lime test windows -dce no %*"
lime test windows -dce no %*
pause
goto build