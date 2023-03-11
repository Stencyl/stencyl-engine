#ifndef NativeDevice
#define NativeDevice

#include <string>

namespace native 
{	
    void initDevice();
	const char* os();
	const char* vervion();
	const char* deviceName();
	const char* model();
	bool networkAvailable();
	void vibrate(float milliseconds);
	void setBadgeNumber(int n);
	void showKeyboard();
	void hideKeyboard();
	void setKeyboardText(const char* text);
	void enableKeyboard(bool flag);
    
    void showSystemAlert(const char* title, const char* message);
    void showLoadingScreen();
    void hideLoadingScreen();
    
    bool SetUserPreference(const char *inId, const char *inPreference);
    std::string GetUserPreference(const char *inId);
    bool ClearUserPreference(const char *inId);

    int getSafeInsetLeft();
    int getSafeInsetTop();
    int getSafeInsetRight();
    int getSafeInsetBottom();
}

#endif
