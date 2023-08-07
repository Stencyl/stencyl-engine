#include <Native.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <netinet/in.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/SCNetworkReachability.h>

UIApplication *app = [UIApplication sharedApplication];
UIWindow * win = app.keyWindow;
UIViewController * rvc = win.rootViewController;

@implementation UIViewController (rvc)

-(UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}

@end

using namespace native;

@interface MyView : NSObject <UITextFieldDelegate>
{
}

@end

@implementation MyView

extern "C" void sendKeyEvent(int key);
extern "C" void sendTextFieldEvent(const char* data);
extern "C" void sendTextFieldEvent2(const char* data);

- (BOOL)textField:(UITextField *)_textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string 
{
   /*if([string length] == 0)
   {
   		//code for backspace?
      	sendKeyEvent(8);
   }
   
   else
   {
   		for(int i = 0; i < [string length]; i++)
      	{
      		unichar c = [string characterAtIndex:i];
			sendKeyEvent(c);
      	}
   }*/
   
   if([string length] == 0)
   {
   		if([_textField.text length] > 0)
   		{
   			NSString* temp = [_textField.text substringToIndex:[_textField.text length] - 1];
   			sendTextFieldEvent([temp UTF8String]);
   		}
   }
   
   else
   {
   		NSString* temp = [_textField.text stringByReplacingCharactersInRange:range withString:string];
		sendTextFieldEvent([temp UTF8String]);
   }

   return YES; // don't allow the edit! (keep placeholder text there) 
}

//Return = auto-hide and maybe an event!
- (BOOL)textFieldShouldReturn:(UITextField*)t 
{
	//mStage->SetFocusObject(0);
	sendTextFieldEvent2([t.text UTF8String]);
    hideKeyboard();
    return YES;
}

@end

namespace native 
{
    UIActivityIndicatorView* activityIndicator;
    UIView* loadingView;
    MyView* keyboardDelegate;
    
    UITextField *mTextField;
    BOOL mKeyboardEnabled;
    
	const char* os()
    {
		return  [[[UIDevice currentDevice] systemName] UTF8String];
	}
    
	const char* vervion()
    {
		return  [[[UIDevice currentDevice] systemVersion] UTF8String];
	}
    
	const char* deviceName()
    {
		return  [[[UIDevice currentDevice] localizedModel] UTF8String];
	}
    
	const char* model()
    {
		return  [[[UIDevice currentDevice] model] UTF8String];
	}
	
    bool networkAvailable()
    {
        // Create zero addy
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        // Recover reachability flags
        SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
        SCNetworkReachabilityFlags flags;
        
        BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
        CFRelease(defaultRouteReachability);
        
        if (!didRetrieveFlags)
        {
            NSLog(@"Error. Could not recover network reachability flags");
            return false;
        }
        
        BOOL isReachable = flags & kSCNetworkFlagsReachable;
        BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
        return (isReachable && !needsConnection) ? true : false;
    }	
    
	void vibrate(float milliseconds)
    {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
	
	void setBadgeNumber(int number)
	{
		[UIApplication sharedApplication].applicationIconBadgeNumber = number;
	}
	
	void showKeyboard()
	{
		enableKeyboard(TRUE);
	}
	
	void hideKeyboard()
	{
		enableKeyboard(FALSE);
	}
	
	void setKeyboardText(const char* text)
	{
		if(mTextField != nil)
		{
			NSString* temp = [[NSString alloc] initWithUTF8String:text];
			mTextField.text = temp;
		}
	}
	
	void enableKeyboard(bool withEnable)
	{
	   if(mKeyboardEnabled != withEnable)
	   {
		   mKeyboardEnabled = withEnable;
		   
		   if(mKeyboardEnabled)
		   {
			  if(mTextField == nil)
			  {
				 mTextField = [[UITextField alloc] initWithFrame: CGRectMake(0,0,0,0)];
	
				 keyboardDelegate = [[MyView alloc] init];
				 mTextField.delegate = keyboardDelegate;
				 
				 mTextField.text = @"";
	
				 /* set UITextInputTrait properties, mostly to defaults */
				 mTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
				 mTextField.autocorrectionType = UITextAutocorrectionTypeNo;
				 mTextField.enablesReturnKeyAutomatically = NO;
				 mTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
				 mTextField.keyboardType = UIKeyboardTypeDefault;
				 mTextField.returnKeyType = UIReturnKeyDefault;
				 mTextField.secureTextEntry = NO;
				 mTextField.hidden = YES;
	
			     [[[UIApplication sharedApplication] keyWindow] addSubview:mTextField];
			  }
			  
			  [mTextField becomeFirstResponder];
		   }
		   
		   else
		   {
			  [mTextField resignFirstResponder];
		   }
	   }
	}
    
    void showSystemAlert(const char *title, const char *message)
    {	
        UIAlertView* alert= [[UIAlertView alloc] initWithTitle: [[NSString alloc] initWithUTF8String:title] message: [[NSString alloc] initWithUTF8String:message] 
                                                      delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] ;
        [alert show];
    }
    
    void showLoadingScreen()
    {
        activityIndicator= [[UIActivityIndicatorView alloc]  initWithFrame:CGRectMake(128.0f, 208.0f, 64.0f,64.0f)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.5;
        [loadingView addSubview:activityIndicator];
        [[[UIApplication sharedApplication] keyWindow] addSubview:loadingView];
        [activityIndicator startAnimating];
    }
    
    void hideLoadingScreen()
    {
        if(activityIndicator != NULL)
        {
            [activityIndicator stopAnimating];
            activityIndicator = NULL;
            
            [loadingView removeFromSuperview];
            loadingView = NULL;
        }
    }
    
	std::string GetUserPreference(const char *inId)
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *strId = [[NSString alloc] initWithUTF8String:inId];
		NSString *pref = [userDefaults stringForKey:strId];
		std::string result(pref?[pref UTF8String]:"");
		return result;
	}

	bool SetUserPreference(const char *inId, const char *inPreference)
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *strId = [[NSString alloc] initWithUTF8String:inId];
		NSString *strPref = [[NSString alloc] initWithUTF8String:inPreference];
		[userDefaults setObject:strPref forKey:strId];
		return true;
	}

	bool ClearUserPreference(const char *inId)
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *strId = [[NSString alloc] initWithUTF8String:inId];
		[userDefaults setObject:@"" forKey:strId];
		return true;
	}
	
	std::vector<std::string> getProgramArguments()
	{
		NSArray *arguments = [[NSProcessInfo processInfo] arguments];
		std::vector<std::string> argArray((int)arguments.count);
		for(int i = 0; i < arguments.count; ++i)
			argArray[i] = std::string([arguments[i] UTF8String]);
		return argArray;
	}
	

	int getSafeInsetLeft()
	{
		if (@available(iOS 11.0, *)) {
			UIWindow *window = [[UIApplication sharedApplication] delegate].window;
			return (int) roundf(window.safeAreaInsets.left * [UIScreen mainScreen].nativeScale);
		}

		return 0;
	}

	int getSafeInsetTop()
	{
		if (@available(iOS 11.0, *)) {
			UIWindow *window = [[UIApplication sharedApplication] delegate].window;
			return (int) roundf(window.safeAreaInsets.top * [UIScreen mainScreen].nativeScale);
		}

		return 0;
	}

	int getSafeInsetRight()
	{
		if (@available(iOS 11.0, *)) {
			UIWindow *window = [[UIApplication sharedApplication] delegate].window;
			return (int) roundf(window.safeAreaInsets.right * [UIScreen mainScreen].nativeScale);
		}

		return 0;
	}

	int getSafeInsetBottom()
	{
		if (@available(iOS 11.0, *)) {
			UIWindow *window = [[UIApplication sharedApplication] delegate].window;
			return (int) roundf(window.safeAreaInsets.bottom * [UIScreen mainScreen].nativeScale);
		}

		return 0;
	}

    //TODO: WebView
}