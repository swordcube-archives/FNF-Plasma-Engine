package native;

#if windows
@:buildXml('
<target id="haxe">
    <lib name="dwmapi.lib" if="windows" />
    <lib name="shell32.lib" if="windows" />
    <lib name="gdi32.lib" if="windows" />
    <lib name="ole32.lib" if="windows" />
    <lib name="uxtheme.lib" if="windows" />
</target>
')

// majority is taken from microsofts doc 
@:cppFileCode('
#include "mmdeviceapi.h"
#include "combaseapi.h"
#include <iostream>
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>

#define SAFE_RELEASE(punk)  \\
              if ((punk) != NULL)  \\
                { (punk)->Release(); (punk) = NULL; }

static long lastDefId = 0;

class AudioFixClient : public IMMNotificationClient {
    LONG _cRef;
    IMMDeviceEnumerator *_pEnumerator;
    
    public:
    AudioFixClient() :
        _cRef(1),
        _pEnumerator(NULL)
    {
        HRESULT result = CoCreateInstance(__uuidof(MMDeviceEnumerator),
                              NULL, CLSCTX_INPROC_SERVER,
                              __uuidof(IMMDeviceEnumerator),
                              (void**)&_pEnumerator);
        if (result == S_OK) {
            _pEnumerator->RegisterEndpointNotificationCallback(this);
        }
    }

    ~AudioFixClient()
    {
        SAFE_RELEASE(_pEnumerator);
    }

    ULONG STDMETHODCALLTYPE AddRef()
    {
        return InterlockedIncrement(&_cRef);
    }

    ULONG STDMETHODCALLTYPE Release()
    {
        ULONG ulRef = InterlockedDecrement(&_cRef);
        if (0 == ulRef)
        {
            delete this;
        }
        return ulRef;
    }

    HRESULT STDMETHODCALLTYPE QueryInterface(
                                REFIID riid, VOID **ppvInterface)
    {
        return S_OK;
    }

    HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR pwstrDeviceId)
    {
        return S_OK;
    };

    HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR pwstrDeviceId)
    {
        return S_OK;
    }

    HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(
                                LPCWSTR pwstrDeviceId,
                                DWORD dwNewState)
    {
        return S_OK;
    }

    HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(
                                LPCWSTR pwstrDeviceId,
                                const PROPERTYKEY key)
    {
        return S_OK;
    }

    HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(
        EDataFlow flow, ERole role,
        LPCWSTR pwstrDeviceId)
    {
        std::cout << "fuck";
        ::Main_obj::audioDisconnected = true;
        return S_OK;
    };
};

AudioFixClient *curAudioFix;
')
@:dox(hide)
class WinAPI {

    public static var __audioChangeCallback:Void->Void = function() {
        trace("test");
    };


    @:functionCode('
    if (!curAudioFix) curAudioFix = new AudioFixClient();
    ')
    public static function registerAudio() {
        Main.audioDisconnected = false;
    }

    @:functionCode('
        int darkMode = enable ? 1 : 0;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
            DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
        }
    ')
    public static function setDarkMode(enable:Bool) {}

    @:functionCode('
    // https://stackoverflow.com/questions/15543571/allocconsole-not-displaying-cout

    if (!AllocConsole())
        return;

    freopen("CONIN$", "r", stdin);
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
    ')
    public static function allocConsole() {
    }

    
    #if windows
    @:functionCode('
        HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE); 
        SetConsoleTextAttribute(console, color);
    ')
    #end
    public static function setConsoleColors(color:Int) {

    }

    #if windows
    @:functionCode('
        system("CLS");
        std::cout<< "" <<std::flush;
    ')
    #end
    public static function clearScreen() {

    }
}
#end