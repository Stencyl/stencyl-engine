#import <UIKit/UIKit.h>
#include <HyperTouch.h>

//---------------------------------------------------------------------------------------------------
	
	typedef void( *FunctionType)( );
	extern "C"{
		void callbackTap(float fx , float fy );	
		void callbackTap2(float fx , float fy );	
		void callbackTwix(float fx , float fy );	
		void callbackSwipe( int direction );
		void callbackRotation( float rotation , float velocity );
		void callbackPan( int phase , float tx , float ty , float vx , float vy , float cx , float cy );		
		void callback( const char * type , float* charArray );	
		void callbackPinch( float scale , float velocity );
	} 

//Interface

	@interface TouchDelegate : NSObject<UIGestureRecognizerDelegate>{ }

		@property ( nonatomic ) FunctionType fOnTap;
		@property ( nonatomic ) FunctionType fOnSwipe;
		@property ( nonatomic ) FunctionType fOnRot;
		@property ( nonatomic ) FunctionType fOnPan;
		@property ( nonatomic ) FunctionType fOnPinch;

		- ( void ) activate:( int ) code;
		- ( void ) deactivate:( int ) code;

		//-( bool ) testGesture : ( NSString* ) codeName;
		-( int ) getOrientation;
		-( void ) handlePan   : ( UIPanGestureRecognizer * ) recognizer;
		-( void ) handlePinch : ( UIPinchGestureRecognizer * ) recognizer;
		-( void ) handleRot   : ( UIRotationGestureRecognizer *) recognizer;
		-( void ) handleSwipe : ( UISwipeGestureRecognizer *)recognizer;
		-( void ) handleTap   : ( UITapGestureRecognizer *) recognizer;
		-( void ) testView;
		-( void ) initGestures;
		//-( BOOL )gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer ;
	@end

// Implementation

	@implementation TouchDelegate

		UIPanGestureRecognizer       *gPan       = nil;
		UIPinchGestureRecognizer     *gPinch     = nil;
		UIRotationGestureRecognizer  *gRotate    = nil;
		UISwipeGestureRecognizer     *gSwipeB    = nil;
		UISwipeGestureRecognizer     *gSwipeL    = nil;
		UISwipeGestureRecognizer     *gSwipeR    = nil;
		UISwipeGestureRecognizer     *gSwipeT    = nil;
		UITapGestureRecognizer       *gSingleTap = nil;
		UITapGestureRecognizer       *gDoubleTap = nil;
		UITapGestureRecognizer       *gTwixTap   = nil;

		UIView *refView;
		BOOL bInit;

		@synthesize fOnTap;
		@synthesize fOnSwipe;
		@synthesize fOnRot;
		@synthesize fOnPan;
		@synthesize fOnPinch;

		//
			- ( id ) init {
				self = [ super init ];
				return self;
			}

			- ( void ) dealloc {
				[ super dealloc ];
			}

			- ( int ) getOrientation{
				return [UIApplication sharedApplication].statusBarOrientation;
			}

		//
			- ( void ) activate:( int ) code{

				if( bInit == false )
					[ self initGestures ];

				NSLog( @"activate ::: %i",code );
				switch( code ){					
					case 0:
						gSingleTap.enabled = YES;
						break;

					case 1:
						gDoubleTap.enabled = YES;
						break;

					case 2:
						gTwixTap.enabled = YES;
						break;

					case 3:
						gPan.enabled = YES;
						break;

					case 4:
						gPinch.enabled = YES;
						break;

					case 5:
						gRotate.enabled = YES;
						break;

					case 6:
						gSwipeB.enabled = YES;
						gSwipeT.enabled = YES;
						gSwipeL.enabled = YES;
						gSwipeR.enabled = YES;
						break;
				}
			}

			- ( void ) deactivate :( int ) code{
				NSLog( @"deactivate ::: %i",code );		
				switch( code ){

					case 0:
						gSingleTap.enabled = NO;
						break;

					case 1:
						gDoubleTap.enabled = NO;
						break;

					case 2:
						gTwixTap.enabled = NO;
						break;

					case 3:
						gPan.enabled = NO;
						break;

					case 4:
						gPinch.enabled = NO;
						break;

					case 5:
						gRotate.enabled = NO;
						break;

					case 6:
						gSwipeB.enabled = NO;
						gSwipeT.enabled = NO;
						gSwipeL.enabled = NO;
						gSwipeR.enabled = NO;
						break;
				}		
			}

			- (void ) testView{
				refView = [[UIView alloc] initWithFrame:CGRectMake(0,0,2,2)];
		        refView.alpha = 0;
		        [[[UIApplication sharedApplication] keyWindow] addSubview:refView];
			}

			-( void ) initGestures{
				NSLog( @"initGestures");

				//
					gPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
					gPinch.delegate = self;
					gPinch.enabled = false;
					[ gPinch setCancelsTouchesInView : NO ];
    				[[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gPinch ];

				//Pan Gesture
					gPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
					gPan.delegate = self;
					gPan.enabled = false;
					[ gPan setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gPan ];

				//Single Tap
					gSingleTap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
					gSingleTap.enabled  = false;
					gSingleTap.delegate = self;
					[ gSingleTap setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gSingleTap ];

				//Double Tap
					gDoubleTap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap2:)];
					gDoubleTap.enabled  = false;
					gDoubleTap.delegate = self;
					[ gDoubleTap setNumberOfTapsRequired    : 2 ];
					[ gDoubleTap setNumberOfTouchesRequired : 1 ];
					[ gDoubleTap setCancelsTouchesInView    : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gDoubleTap ];

				//Two Fingers Tap
					gTwixTap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwix:)];
					gTwixTap.enabled  = false;
					gTwixTap.delegate = self;
					[ gTwixTap setNumberOfTapsRequired    : 1 ];
					[ gTwixTap setNumberOfTouchesRequired : 2 ];
					[ gTwixTap setCancelsTouchesInView    : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gTwixTap ];

				//Mixer
					[gSingleTap requireGestureRecognizerToFail:gDoubleTap];
					[gSingleTap requireGestureRecognizerToFail:gTwixTap];

				//Rotation
					gRotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRot:)];
					gRotate.delegate = self;
					gRotate.enabled = false;
					[ gRotate setCancelsTouchesInView : NO ];
    				[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gRotate ];

				//Swipe Left
					gSwipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
					[ gSwipeL setDirection : UISwipeGestureRecognizerDirectionLeft ];
					gSwipeL.enabled = false;
					gSwipeL.delegate = self;
					[ gSwipeL setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gSwipeL ];
					[gSwipeL requireGestureRecognizerToFail:gPan];

				//Swipe Right
					gSwipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
					[ gSwipeR setDirection : UISwipeGestureRecognizerDirectionRight ];
					gSwipeR.enabled = false;
					gSwipeR.delegate = self;
					[ gSwipeR setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gSwipeR ];

				//Swipe Top
					gSwipeT = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
					[ gSwipeT setDirection : UISwipeGestureRecognizerDirectionUp ];
					gSwipeT.enabled = false;
					gSwipeT.delegate = self;
					[ gSwipeT setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gSwipeT ];

				//Swipe Bottom
					gSwipeB = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
					[ gSwipeB setDirection : UISwipeGestureRecognizerDirectionDown ];
					gSwipeB.enabled = false;
					gSwipeB.delegate = self;
					[ gSwipeB setCancelsTouchesInView : NO ];
					[ [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addGestureRecognizer:gSwipeB ];	

				bInit = true;			
			}

			- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
			   // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
			    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
			        return NO;

			   	if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
			        return NO;

			    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
			        return NO;

			    //UIPanGestureRecognizer
			    /*
			    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
			        return NO;
				*/
				
			    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]])
			        return NO;

			    return YES;
			}

		//---------------------------------------------------------------------------------------------------
			
			- ( void ) handleTap : ( UITapGestureRecognizer *) recognizer { 
				
				CGPoint tapPoint = [ 
										recognizer locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view
									];
				callbackTap( 
								tapPoint.x , 
								tapPoint.y 
							);
				
			}

			- ( void ) handleTap2 : ( UITapGestureRecognizer *) recognizer { 
				
				CGPoint tapPoint = [ 
										recognizer locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view
									];
				callbackTap2( 
								tapPoint.x , 
								tapPoint.y 
							);
			}

			- ( void ) handleTwix : ( UITapGestureRecognizer *) recognizer { 
				
				CGPoint tapPoint = [ 
										recognizer locationInView:[UIApplication sharedApplication].keyWindow.rootViewController.view
									];
				
				callbackTwix( 
								tapPoint.x , 
								tapPoint.y 
							);
			}

			- (void)handleSwipe:( UISwipeGestureRecognizer *)recognizer {
				NSLog( @"handleSwipe %i" , recognizer.direction );
				if( recognizer.state == UIGestureRecognizerStateEnded ) {
					
					if (![recognizer isEnabled]) 
						return;    
	    				[recognizer setEnabled:NO];
	   					[recognizer performSelector:@selector(setEnabled:) withObject: [NSNumber numberWithBool:YES] afterDelay:0.1];

					NSLog( @"handleSwipe %i" , recognizer.direction );
					callbackSwipe( recognizer.direction );
				}

				
			}

			- (void)handleRot:( UIRotationGestureRecognizer *) recognizer{
				//NSLog( @"handleRotation rotation %f velocity : %f " , recognizer.rotation , recognizer.velocity);
				callbackRotation( recognizer.rotation , recognizer.velocity );
			}

			- (void)handlePan:( UIPanGestureRecognizer * ) recognizer{

				int phase = -1;
				if( recognizer.state == UIGestureRecognizerStateBegan )
					phase = 0;

				if( recognizer.state == UIGestureRecognizerStateChanged )
					phase = 1;

				if( recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled )
					phase = 2;

				NSLog( @"handlePan %i" , phase );
				if ( phase != -1 ){
					CGPoint translation	= [ recognizer translationInView:recognizer.view];
					CGPoint center		= [ recognizer locationInView:recognizer.view ];
					CGPoint velocity	= [ recognizer velocityInView:recognizer.view];
					NSLog( @"handlePan location %@ , velocity %@" , NSStringFromCGPoint( translation ) , NSStringFromCGPoint(velocity));
					callbackPan( phase , translation.x , translation.y , velocity.x , velocity.y , center.x , center.y );
					[recognizer setTranslation:CGPointMake(0, 0) inView : recognizer.view];
				}
				
			}

			-( void ) handlePinch:( UIPinchGestureRecognizer * ) recognizer{
				//NSLog( @"handlePinch scale %f, velocity %f",recognizer.scale,recognizer.velocity);
				callbackPinch( recognizer.scale , recognizer.velocity );
			}

		//---------------------------------------------------------------------------------------------------
			

	@end

//---------------------------------------------------------------------------------------------------
	
	//Callback externs
		extern "C"{
			
		}

	namespace Hyperfiction{
		
		const int TAP = 0;
	
		static bool *bTap_ON     = false;
		static bool *bTap2_ON    = false;
		static TouchDelegate *td;

		//
			void init_hyp_touch( ){
				NSLog( @"init" );
				td = [ TouchDelegate alloc ];
				[ td testView ];
			}


		//Activators
		//-----------------------------------------------------------
			
			bool activateGesture( int gestureCode ){
				NSLog( @"activateGesture %i" , gestureCode );
				[ td activate : gestureCode ];
			}

			bool deactivateGesture( int gestureCode ){
				NSLog( @"deactivateGesture %i" , gestureCode );
				[ td deactivate : gestureCode ];
			}

		//Misc

			int getOrientation( ){
				return [ td getOrientation ];
			}


	}
