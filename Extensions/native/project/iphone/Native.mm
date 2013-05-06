#include <Native.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <netinet/in.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SystemConfiguration/SCNetworkReachability.h>

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
   		NSString* temp = _textField.text;
		temp = [NSString stringWithFormat:@"%@%@", temp, string];
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
			[temp release];
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
				 #ifndef OBJC_ARC
				 mTextField = [[[UITextField alloc] initWithFrame: CGRectMake(0,0,0,0)] autorelease];
				 #else
				 mTextField = [[UITextField alloc] initWithFrame: CGRectMake(0,0,0,0)];
				 #endif
	
				 mTextField.delegate = [[MyView alloc] init];
				 
				 /* placeholder so there is something to delete! (from SDL code) */
				 mTextField.text = @" ";
	
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
                                                      delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL] ;//autorelease];
        [alert show];
        //[alert release];
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
            [activityIndicator release];
            activityIndicator = NULL;
            
            [loadingView removeFromSuperview];
            [loadingView release];
            loadingView = NULL;
        }
    }
    
    //TODO: WebView
}