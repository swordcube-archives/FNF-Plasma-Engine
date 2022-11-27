
package funkin.windows;

/**
 * Class for Windows-only functions, such as transparent windows, message boxes, and more.
 * Does not have any effect on other platforms.
 * 
 * THIS WAS MADE BY YOSHICRAFTER29!!! I HAVE NO CLUE WHAT THE FUCK THIS DOES LMAO!!
 */
class WindowsAPI {
    @:dox(hide) public static function registerAudio() {
        #if windows
        native.WinAPI.registerAudio();
        #end
    }
    
    /**
     * Allocates a new console. The console will automatically be opened
     */
    public static function allocConsole() {
        #if windows
        native.WinAPI.allocConsole();
        native.WinAPI.clearScreen();
        #end
    }

    /**
     * Clears the console.
     * @author swordcube
     */
     public static function clearScreen() {
        #if windows
        native.WinAPI.clearScreen();
        #end
    }

    /**
     * Sets the window titlebar to dark mode (Windows 10 only)
     */
    public static function setDarkMode(enable:Bool) {
        #if windows
        native.WinAPI.setDarkMode(enable);
        #end
    }

    /**
     * Sets the console colors
     */
    public static function setConsoleColors(foregroundColor:ConsoleColor = LIGHTGRAY, ?backgroundColor:ConsoleColor = BLACK) {
        #if windows
        var fg = cast(foregroundColor, Int);
        var bg = cast(backgroundColor, Int);
        native.WinAPI.setConsoleColors((bg * 16) + fg);
        #end
    } 

    public static function consoleColorToOpenFL(color:ConsoleColor) {
        return switch(color) {
            case BLACK:         0xFF000000;
            case DARKBLUE:      0xFF000088;
            case DARKGREEN:     0xFF008800;
            case DARKCYAN:      0xFF008888;
            case DARKRED:       0xFF880000;
            case DARKMAGENTA:   0xFF880000;
            case DARKYELLOW:    0xFF888800;
            case LIGHTGRAY:     0xFFBBBBBB;
            case GRAY:          0xFF888888;
            case BLUE:          0xFF0000FF;
            case GREEN:         0xFF00FF00;
            case CYAN:          0xFF00FFFF;
            case RED:           0xFFFF0000;
            case MAGENTA:       0xFFFF00FF;
            case YELLOW:        0xFFFFFF00;
            case WHITE | _:     0xFFFFFFFF;
        }
    }
}

@:enum abstract ConsoleColor(Int) {
    var BLACK:ConsoleColor = 0;
    var DARKBLUE:ConsoleColor = 1;
    var DARKGREEN:ConsoleColor = 2;
    var DARKCYAN:ConsoleColor = 3;
    var DARKRED:ConsoleColor = 4;
    var DARKMAGENTA:ConsoleColor = 5;
    var DARKYELLOW:ConsoleColor = 6;
    var LIGHTGRAY:ConsoleColor = 7;
    var GRAY:ConsoleColor = 8;
    var BLUE:ConsoleColor = 9;
    var GREEN:ConsoleColor = 10;
    var CYAN:ConsoleColor = 11;
    var RED:ConsoleColor = 12;
    var MAGENTA:ConsoleColor = 13;
    var YELLOW:ConsoleColor = 14;
    var WHITE:ConsoleColor = 15;
}