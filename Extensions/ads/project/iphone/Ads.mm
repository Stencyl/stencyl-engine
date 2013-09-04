#include <Ads.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <iAd/iAd.h>




// NOTE:  These classes are using some methods that are deprecated as of IOS 6
// such as setRequiredContentSizeIdentifiers and setCurrentContentSizeIdentifier.
// They still work for now and I don't know how they could be worked around.
// Someday they might have to be addressed, but not today.

extern "C" void sendEvent(char* event);

@interface AdController : UIViewController <ADBannerViewDelegate>
{
    ADBannerView* _bannerView;
    UIView* _contentView;
    BOOL _isVisible; //user set
    BOOL _isLoaded; //iOS set
    BOOL _onBottom;
    BOOL _processRotations;  // Should I do my stuff?
}

@property (nonatomic, retain) ADBannerView* bannerView;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL onBottom;
@property (nonatomic) BOOL processRotations;

-(void)moveToTop;
-(void)moveToBottom;
-(void)showAd;
-(void)hideAd;
-(void)fixupAdView:(UIInterfaceOrientation)toDeviceOrientation; 

@end

@implementation AdController

@synthesize bannerView = _bannerView;
@synthesize contentView = _contentView;
@synthesize visible = _isVisible;
@synthesize onBottom = _onBottom;
@synthesize processRotations = _processRotations;


-(void)moveToTop
{
	NSLog(@"Move Ad to Top");
	_onBottom = false;	
   	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];  
}

-(void)moveToBottom
{
	NSLog(@"Move Ad to Bottom");
	_onBottom = true;	
   	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)showAd
{
	NSLog(@"Developer Set Ad to Visible");
	_isVisible = true;	
   	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)hideAd
{
	NSLog(@"Developer Set Ad to Hidden");
	_isVisible = false;
	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView*)banner willLeaveApplication:(BOOL)willLeave
{
	NSLog(@"User opened ad.");
	sendEvent("open");

	_isLoaded = false;
	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];

    _processRotations = NO;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView*)banner
{
	NSLog(@"User closed ad.");
	sendEvent("close");
	
	_isLoaded = true;
	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
    
    _processRotations = YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView*)banner
{
    NSLog(@"Loaded ad. Show it (if Developer set to visible).");
    sendEvent("load");
    
    _isLoaded = true;
    _bannerView.hidden = NO;  
    
    [self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)bannerView:(ADBannerView*)banner didFailToReceiveAdWithError:(NSError*)error
{
    NSLog(@"Could not load ad. Hide it for now.");
    NSLog(@"%@", [error localizedDescription]);
    sendEvent("fail");
    
    _isLoaded = false;

   	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    NSLog(@"Ad Controller saying YES to auto-rotate.");
    return YES;
}

- (void)orientationChanged:(NSNotification*)notification
{
    if (_processRotations == NO)
    {
        return;  // Do Nothing!
    }
    
	// Doing this here because fixupAdView gets called alot for other than orinetation changes and don't want to thrash the ad content downloads.
	UIInterfaceOrientation toOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if(UIInterfaceOrientationIsLandscape(toOrientation)) 
	{
		NSLog(@"Changing ad orientation to landscape...");
		[_bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierLandscape, nil]];
    } 
	else 
	{
		NSLog(@"Changing ad orientation to portrait...");
		[_bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, nil]];
    }

	[self fixupAdView:toOrientation];
}


- (void)viewWillAppear:(BOOL)animated 
{
    NSLog(@"Ad View will appear...");
    [self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}




-(int)getBannerHeight:(UIInterfaceOrientation)orientation
{
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            return 66;
        }
        else
        {
            return 32;
        }
    }
    
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            return 66;
        }
        else
        {
            return 50;
        }
    }
}





//  Normal [UIScreen mainScreen] will always report portrait mode.  So check current orientation and
//  return a properly corrected Size if landscape.
- (CGSize)getCorrectedSize
{
	CGSize correctSize;
	UIInterfaceOrientation toOrientation = [UIApplication sharedApplication].statusBarOrientation;
	correctSize = [[UIScreen mainScreen] bounds].size;
	if(UIInterfaceOrientationIsLandscape(toOrientation))
	{
		correctSize.height = [[UIScreen mainScreen] bounds].size.width;
		correctSize.width = [[UIScreen mainScreen] bounds].size.height;
	}
	
	return correctSize;
}


//NOTE: This approach simply overlays the ad view on top of the scene.  I think thats the way it
//      was originally working.  However, it might be possible to place the ad view and SHIFT the
//      game view over instead of overlay (some of the game view would spill off screen).
//      Maybe eventuallly that could exposed as a user selection and used here like IsHidden.
- (void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_bannerView != nil)
    {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [_bannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
        } else {
            [_bannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        }
        
        int bannerHeight = [self getBannerHeight:toInterfaceOrientation];
        CGSize screenSize = [self getCorrectedSize];
        [UIView beginAnimations:@"fixupViews" context:nil];
        if (_isVisible && ![_bannerView isHidden] && _isLoaded)
        {
            NSLog(@"fixupAdView - Ad is Visible");
            
            CGRect adBannerViewFrame = [_bannerView frame];
            adBannerViewFrame.origin.x = 0;
            if(_onBottom)
            {
                adBannerViewFrame.origin.y = screenSize.height - bannerHeight;
            }
            else
            {
                adBannerViewFrame.origin.y = 0;
            }
            [_bannerView setFrame:adBannerViewFrame];

        }
        else
        {
            NSLog(@"fixupAdView - Ad is not Visible or Hidden or not Loaded");
            CGRect adBannerViewFrame = [_bannerView frame];
            adBannerViewFrame.origin.x = 0;
            if(_onBottom)
            {
                adBannerViewFrame.origin.y = screenSize.height + bannerHeight;
            }
            else
            {
                adBannerViewFrame.origin.y = -bannerHeight;
            }
            [_bannerView setFrame:adBannerViewFrame];
         }
        [UIView commitAnimations];
    }
}



namespace ads
{	
    static AdController* adController;
    
    void init()
    {
        

		//  This is a bit of voodoo I saw on Stacktrace to force getting a proper orientation during launch when things can report screwy.
		//  QUOTE: statusBarOrientation will always be portrait until after application:didFinishLaunchingWithOptions:. The only caveat is that 
		//  you need to enable device orientation notifications prior or asking UIDevice for the orientation.
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		UIDeviceOrientation currentDeviceOrientation = [[UIDevice currentDevice] orientation];
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];


        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		
		Class classAdBannerView = NSClassFromString(@"ADBannerView");
		if(classAdBannerView != nil) 
		{            
			ADBannerView* _adBannerView = [[[classAdBannerView alloc] initWithFrame:CGRectZero] autorelease];
            if(UIDeviceOrientationIsLandscape(currentDeviceOrientation))
            {
                NSLog(@"Initializing ad banner content to landscape...");
                [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierLandscape, nil]];
            }
            else
            {
                NSLog(@"Initializing ad banner content to portrait...");
                [_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, nil]];
            }
            
            
            
			AdController* ac = [[AdController alloc] init];
            ac.processRotations = YES;
            
            adController = ac;
			[[NSNotificationCenter defaultCenter] addObserver:ac selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
            
            ac.bannerView = _adBannerView;
            [_adBannerView setDelegate:ac];
            ac.contentView = window.rootViewController.view;
            // for the ads to behave properly they need to be owned by the RootViewControler that
            // is also controlling the UISTageView
            _adBannerView.hidden = YES; // It will be unhidden at first load
            [window.rootViewController.view addSubview:ac.bannerView];
 			[ac fixupAdView:currentDeviceOrientation];
            
            
        }

		[pool drain];
    }
 
    
    void showAd(int position)
    {
        NSLog(@"Showing ad...");
        if(adController == NULL)
        {
            NSLog(@"Need to init ad controller first");
            init();
        }
        
        if(position == 0)
        {
            [adController moveToBottom];
        }
        
        else
        {
            [adController moveToTop];
        }
        
        [adController showAd];
    }
    
    void hideAd()
    {
        NSLog(@"Hiding ad...");
        if(adController == NULL)
        {
            NSLog(@"Need to init ad controller first");
            init();
        }
        
        [adController hideAd];
    }
    

}

@end

