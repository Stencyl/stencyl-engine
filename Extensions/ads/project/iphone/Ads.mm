#include <Ads.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <iAd/iAd.h>

//---

@interface GlassPane : UIView
@end

@implementation GlassPane

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    for(UIView *subview in self.subviews)
    {
    	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    	CGPoint innerPoint;
    	
    	if(UIInterfaceOrientationIsLandscape(o))
    	{
    		innerPoint = CGPointMake(point.y - subview.frame.origin.y, point.x - subview.frame.origin.x);
    	}
    	
    	else
    	{
    		innerPoint = CGPointMake(point.x - subview.frame.origin.x, point.y - subview.frame.origin.y);
    	}
                              
        if([subview pointInside:innerPoint withEvent:event]) 
        {
        	return YES;
        }
    }
    
    return NO;
}

@end

//---

@interface GlassPaneViewController : UIViewController
{
}

@end

@implementation GlassPaneViewController 

- (void)loadView
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.view = [[GlassPane alloc] initWithFrame:screenBounds];
}

@end

//---

extern "C" void sendEvent(char* event);

@interface AdController : UIViewController <ADBannerViewDelegate>
{
    ADBannerView* _bannerView;
    UIView* _contentView;
    BOOL _isVisible; //user set
    BOOL _isLoaded; //iOS set
    BOOL _onBottom;
}

@property (nonatomic, retain) ADBannerView* bannerView;
@property (nonatomic, retain) UIView* contentView;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL onBottom;

-(void)moveToTop;
-(void)moveToBottom;
-(void)showAd;
-(void)hideAd;
-(void)fixupAdView:(UIInterfaceOrientation)toDeviceOrientation;
-(int)getBannerHeight:(UIInterfaceOrientation)orientation;

@end

@implementation AdController

@synthesize bannerView = _bannerView;
@synthesize contentView = _contentView;
@synthesize visible = _isVisible;
@synthesize onBottom = _onBottom;

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
	//[self hideAd];
}

- (void)bannerViewActionDidFinish:(ADBannerView*)banner
{
	NSLog(@"User closed ad.");
	sendEvent("close");
	
	_isLoaded = true;
	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
	//[self showAd];
}

- (void)bannerViewDidLoadAd:(ADBannerView*)banner
{
    NSLog(@"Loaded ad. Show it (if Developer set to visible).");
    sendEvent("load");
    
    _isLoaded = true;
    
    /*if(!_isVisible)
    {
    	[self showAd];
    }*/
    
    [self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)bannerView:(ADBannerView*)banner didFailToReceiveAdWithError:(NSError*)error
{
    NSLog(@"Could not load ad. Hide it for now.");
    sendEvent("fail");
    
    _isLoaded = false;
   
    /*if(_isVisible)
    {
   		[self hideAd];
   	}*/
   	
   	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (void)orientationChanged:(NSNotification*)notification
{   
	[self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [self fixupAdView:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)fixupAdView:(UIInterfaceOrientation)toDeviceOrientation 
{
    if(_bannerView != nil) 
    {
        if(UIInterfaceOrientationIsLandscape(toDeviceOrientation)) 
        {
            [_bannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
        } 
        
        else 
        {
            [_bannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        }
        
        //[UIView beginAnimations:@"fixupViews" context:nil];
        
        if(_isVisible &&_isLoaded) 
        {
        	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        	CGSize adBannerViewSize = [_bannerView frame].size;
        	
        	float bannerWidth = adBannerViewSize.width;
        	float bannerHeight = adBannerViewSize.height;

			#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
			#else
			NSLog(@"Flip Banner Dimensions on lower versions of iOS");
			
			//Early on, the banner size can be flipped. This protects against that.
			if(bannerWidth > bannerHeight && UIInterfaceOrientationIsLandscape(toDeviceOrientation))
			{
				bannerWidth = adBannerViewSize.height;
        	 	bannerHeight = adBannerViewSize.width;
			}
			#endif

			//NSLog(@"Banner Size: %f %f", bannerWidth, bannerHeight);
			[(UIView*)_bannerView setTransform:CGAffineTransformIdentity];
			[_bannerView setFrame:CGRectMake(0.f, 0.f, bannerWidth, bannerHeight)];
	
			NSLog(@"Visible");
	
			//Set the transformation for each orientation
			switch(toDeviceOrientation)
			{
				case UIInterfaceOrientationPortrait:
				{
					NSLog(@"UIInterfaceOrientationPortrait");

					if(_onBottom)
					{
						[_bannerView setCenter:CGPointMake(screenSize.width/2, screenSize.height - bannerHeight/2)];
					}
					
					else
					{
						[_bannerView setCenter:CGPointMake(screenSize.width/2, bannerHeight/2)];
					}
					
					if([_bannerView isHidden])
					{
						NSLog(@"Hidden");
						
						if(_onBottom)
						{
							[_bannerView setCenter:CGPointMake(screenSize.width/2, screenSize.height + bannerHeight/2)];
						}
						
						else
						{
							[_bannerView setCenter:CGPointMake(screenSize.width/2, -bannerHeight/2)];
						}
					}
				}
				
				break;
				
				case UIInterfaceOrientationPortraitUpsideDown:
				{
					NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
					[(UIView*)_bannerView setTransform:CGAffineTransformMakeRotation(M_PI)];
					
					if(_onBottom)
					{
						[_bannerView setCenter:CGPointMake(screenSize.width/2, bannerHeight/2)];
					}
					
					else
					{
						[_bannerView setCenter:CGPointMake(screenSize.width/2, screenSize.height - bannerHeight/2)];
					}
					
					if([_bannerView isHidden])
					{
						NSLog(@"Hidden");
						
						if(_onBottom)
						{
							[_bannerView setCenter:CGPointMake(screenSize.width/2, -bannerHeight/2)];
						}
						
						else
						{
							[_bannerView setCenter:CGPointMake(screenSize.width/2, screenSize.height + bannerHeight/2)];
						}
					}
				}
				
				break;
				
				case UIInterfaceOrientationLandscapeRight:
				{
					NSLog(@"UIInterfaceOrientationLandscapeRight");
					[(UIView*)_bannerView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
					
					if(_onBottom)
					{
						#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
						[_bannerView setCenter:CGPointMake(bannerHeight/2, screenSize.height/2)];
						#else
						[_bannerView setCenter:CGPointMake(bannerWidth/2, screenSize.height/2)];
						#endif
					}
					
					else
					{
						#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
						[_bannerView setCenter:CGPointMake(screenSize.width - bannerHeight/2, screenSize.height/2)];
						#else
						[_bannerView setCenter:CGPointMake(screenSize.width - bannerWidth/2, screenSize.height/2)];
						#endif
					}
					
					if([_bannerView isHidden])
					{
						NSLog(@"Hidden");
						
						if(_onBottom)
						{			
							#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0	
							[_bannerView setCenter:CGPointMake(-bannerHeight/2, screenSize.height/2)];
							#else	
							[_bannerView setCenter:CGPointMake(-bannerHeight/2, screenSize.height/2)];
							#endif
						}
						
						else
						{
							[_bannerView setCenter:CGPointMake(screenSize.width + bannerWidth/2, screenSize.height/2)];
						}
					}
				}
				
				break;
				
				case UIInterfaceOrientationLandscapeLeft:
				{
					NSLog(@"UIInterfaceOrientationLandscapeLeft");
					[(UIView*)_bannerView setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
					
					if(_onBottom)
					{
						#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
						[_bannerView setCenter:CGPointMake(screenSize.width - bannerHeight/2, screenSize.height/2)];
						#else
						[_bannerView setCenter:CGPointMake(screenSize.width - bannerWidth/2, screenSize.height/2)];
						#endif
					}
					
					else
					{
						#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
						[_bannerView setCenter:CGPointMake(bannerHeight/2, screenSize.height/2)];
						#else
						[_bannerView setCenter:CGPointMake(bannerWidth/2, screenSize.height/2)];
						#endif
					}
					
					if([_bannerView isHidden])
					{
						NSLog(@"Hidden");
						
						if(_onBottom)
						{
							#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
							[_bannerView setCenter:CGPointMake(screenSize.width + bannerHeight/2, screenSize.height/2)];
							#else
							[_bannerView setCenter:CGPointMake(screenSize.width + bannerWidth/2, screenSize.height/2)];
							#endif
						}
						
						else
						{
							[_bannerView setCenter:CGPointMake(-bannerHeight/2, screenSize.height/2)];
						}
					}
				}
				
				break;
					
				default:
					break;
			}
        } 
        
        else 
        {
        	NSLog(@"NOT Visible");
        
            CGRect adBannerViewFrame = [_bannerView frame];
            adBannerViewFrame.origin.x = 0;
            adBannerViewFrame.origin.y = -9999;
            [_bannerView setFrame:adBannerViewFrame];
        }
        
        //[UIView commitAnimations];
    }   
}

-(int)getBannerHeight:(UIInterfaceOrientation)orientation 
{
    if(UIInterfaceOrientationIsLandscape(orientation)) 
    {
        return 32;
    } 
    
    else 
    {
        return 50;
    }
}

@end

//---

namespace ads
{	
    static AdController* adController;

    void init()
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		
		Class classAdBannerView = NSClassFromString(@"ADBannerView");
		
		if(classAdBannerView != nil) 
		{
			AdController* c = [[AdController alloc] init];
            adController = c;

			ADBannerView* _adBannerView = [[[classAdBannerView alloc] initWithFrame:CGRectZero] autorelease];
			c.bannerView = _adBannerView;
			
			#if defined(__IPHONE_6_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
			if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) 
			{
				[_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierLandscape, ADBannerContentSizeIdentifierPortrait, nil]];
			}
			
			else
			{
				[_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierPortrait, nil]];
			}
			
			#else
			[_adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: ADBannerContentSizeIdentifierLandscape, ADBannerContentSizeIdentifierPortrait, nil]];
			#endif
			
			//[_adBannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
			
			int bannerHeight = 0;
			
			if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) 
			{
				[_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
				bannerHeight = 32;
			} 
			
			else 
			{
				[_adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];  
				bannerHeight = 50;
			}

			[_adBannerView setFrame:CGRectOffset([_adBannerView frame], 0, -9999)];
			[_adBannerView setDelegate:c];
	
			[[NSNotificationCenter defaultCenter] addObserver:c selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
			
			GlassPaneViewController* vc = [[GlassPaneViewController alloc] init];
            c.contentView = vc.view;
            
            //iOS 6
            [window addSubview:vc.view];
            
            [vc.view addSubview:_adBannerView];     
		}

		[pool drain];
    }
    
    void showAd(int position)
    {
        if(adController == NULL)
        {
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
        if(adController == NULL)
        {
            init();
        }
        
        [adController hideAd];
    }
}