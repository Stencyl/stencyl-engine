package fr.hyperfiction;

#if code_completion

@final extern class HyperTouch{
	static var SWIPE_DIRECTION_RIGHT : Int;
	static var SWIPE_DIRECTION_LEFT  : Int;
	static var SWIPE_DIRECTION_UP    : Int;
	static var SWIPE_DIRECTION_DOWN  : Int;
	function getInstance( ) : HyperTouch;
	function addEventListener(type : String, listener : Dynamic -> Void, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void;
	function removeEventListener(type : String, listener : Dynamic -> Void, useCapture : Bool = false ) : Void;
}

#else

#if android
import nme.JNI;
#end

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import fr.hyperfiction.events.GesturePanEvent;
import fr.hyperfiction.events.GesturePinchEvent;
import fr.hyperfiction.events.GestureRotationEvent;
import fr.hyperfiction.events.GestureSwipeEvent;
import fr.hyperfiction.events.GestureTapEvent;
import nme.Lib;
import nme.display.Stage;
import nme.errors.Error;
import nme.events.Event;
import nme.events.EventDispatcher;


/**
 * ...
 * @author shoe[box]
 */

class HyperTouch extends EventDispatcher{
	
	public static inline var SWIPE_DIRECTION_RIGHT : Int = 1;
	public static inline var SWIPE_DIRECTION_LEFT  : Int = 2;
	public static inline var SWIPE_DIRECTION_UP    : Int = 4;
	public static inline var SWIPE_DIRECTION_DOWN  : Int = 8;

	#if !air
	private static var hyp_touch_callback_pan      = Lib.load( "hypertouch" , "hyp_touch_callback_pan", 1);
	private static var hyp_touch_callback_pinch    = Lib.load( "hypertouch" , "hyp_touch_callback_pinch", 1);
	private static var hyp_touch_callback_rotation = Lib.load( "hypertouch" , "hyp_touch_callback_rotation", 1);
	private static var hyp_touch_callback_swipe    = Lib.load( "hypertouch" , "hyp_touch_callback_swipe", 1);
	private static var hyp_touch_callback_tap      = Lib.load( "hypertouch" , "hyp_touch_callback_tap", 1);
	private static var hyp_touch_callback_tap2     = Lib.load( "hypertouch" , "hyp_touch_callback_tap2", 1);
	private static var hyp_touch_callback_twix     = Lib.load( "hypertouch" , "hyp_touch_callback_twix", 1);
	#end
	
	#if iphone
	private static var hyp_touch_activate          = Lib.load( "HyperTouch" , "hyp_touch_activate" , 1 );
	private static var hyp_touch_deactivate        = Lib.load( "HyperTouch" , "hyp_touch_deactivate" , 1 );
	private static var hyp_touch_get_orientation   = Lib.load( "HyperTouch" , "hyp_touch_get_orientation" , 0 );
	private static var hypTouch_init = nme.Loader.load( "hyp_touch_init" , 0 );
	private var _fTmp : FPoint;
	#end

	#if android	
	public static inline var ANDROID_CLASS : String = 'fr.hyperfiction.HyperTouch';

	static private var hyp_touch_init	: Dynamic;
	static private var hyp_touch_toggle	: Dynamic;
	#end

	public static inline var GestureCode_TAP : Int = 0;


	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		private function new( ) {
			trace('constructor');
			super( );

			#if(iphone && !air)
				hypTouch_init( );
				_fTmp = { x : 0.0 , y : 0.0 };
				
			#end

			#if(mobile && !air)
				hyp_touch_callback_pan( _onPanCallback );
				hyp_touch_callback_pinch( _onPinchCallback );
				hyp_touch_callback_rotation( _onRotCallback );
				hyp_touch_callback_swipe( _onSwipeCallback );
				hyp_touch_callback_tap2( _onTap2Callback );
				hyp_touch_callback_twix( _onTwixCallback );
				hyp_touch_callback_tap( _onTapCallback );
			#end

			#if android

			//Initialize JNI Methods
					
				if( hyp_touch_init == null )
					hyp_touch_init = JNI.createStaticMethod( ANDROID_CLASS , 'HyperTouch_init' , "()V" );
					hyp_touch_init( );

				if( hyp_touch_toggle == null )
					hyp_touch_toggle = JNI.createStaticMethod( ANDROID_CLASS , 'HyperTouch_toggle' , "(IZ)V" );
					
			#end

		}
	
	// -------o public

		/**
		* Overriding the <code>EventDispatcher.addEventListener</code>
		* To activate only the gesture who are listened
		* 
		* @public
		* @return	void
		*/
		override public function addEventListener(
													type : String, 
													listener : Dynamic -> Void, 
													useCapture : Bool = false, 
													priority : Int = 0, 
													useWeakReference : Bool = false
													) : Void{

			
			super.addEventListener( type , listener , useCapture , priority , useWeakReference );
			
			#if iphone
			hyp_touch_activate( getCode( type ) );
			#end

			#if android
			hyp_touch_toggle( getCode( type ) , true );
			#end
		}

		/**
		* Overriding the <code>EventDispatcher.addEventListener</code>
		* To deactivate only the gesture who are no more listened
		* 
		* @public
		* @return	void
		*/
		override public function removeEventListener(
														type : String, 
														listener : Dynamic -> Void, 
														useCapture : Bool = false
													) : Void{
			super.removeEventListener( type , listener , useCapture );
			_disable( type );
		}

		/**
		* Get the Gesture code by Type 
		* 
		* @public
		* @return	gestur code ( Int )
		*/
		public function getCode( type : String ) : Int {

			var e = Type.createEnum( Gestures , type );
			return Type.enumIndex( e );			
		}

	// -------o protected
		
		#if mobile

		/**
		* Callback of the Pan
		* 
		* @private
		* @param 	args : Callback arguments coordinates ( Array<Float> )
		* @return	void
		*/
		private function _onPanCallback( args : Array<Float> ) : Void{
			Reflect.callMethod( this , _onDispatchPan , args );
		}
	
		/**
		* Callback of the Pinch Listener
		* 
		* @private
		* @param 	fScale    : Pinch Scale Value ( Float )
		* @param 	fVelocity : Velocity of the pinch ( Float )
		* @return	void
		*/
		#if android
		private function _onPinchCallback( fScale : Float ) : Void{
			try{
				_onDispatchPinch( fScale , 0.0 );	
			}catch( e : nme.errors.Error ){
				trace('error :: '+e);
			}
			
		}
		#else
		private function _onPinchCallback( fScale : Float , fVelocity : Float ) : Void{
			_onDispatchPinch( fScale , fVelocity );
		}
		#end

		/**
		* Callback of the rotation listener
		* 
		* @private
		* @param	fRotation : Rotation value ( Float )
		* @param	fVelocity : Velocity of the rotation gesture ( Float )
		* @return	void
		*/
		private function _onRotCallback( fRotation : Float , fVelocity : Float ) : Void{
			_onDispatchRotation( fRotation , fVelocity );
		}

		/**
		* Callback of the swipe gesture
		* 
		* @private
		* @param	direction : Direction of gesture ( Int )
		* @return	void
		*/
		private function _onSwipeCallback( direction : Int ) : Void{
			_onDispatchSwipe( direction );
		}		

		/**
		* Tap Callback
		* 
		* @private
		* @param	fx : Location X of the Tap ( Float )
		* @param	fy : Location Y of the Tap ( Float )
		* @return	void
		*/
		private function _onTapCallback( fx : Float , fy : Float ) : Void{
			#if iphone
			var res = _convertToGl( fx , fy );
			_onDispatchTap( res.x , res.y , 1 , 1 );
			#else
			_onDispatchTap( fx , fy , 1 , 1 );
			#end
			
		}

		/**
		* Double Tap Callback
		* 
		* @private
		* @param	fx : Location X of the Tap ( Float )
		* @param	fy : Location Y of the Tap ( Float )
		* @return	void
		*/
		private function _onTap2Callback( fx : Float , fy : Float ) : Void{
			#if iphone
			var res = _convertToGl( fx , fy );
			_onDispatchTap( res.x , res.y , 1 , 2 );
			#else
			_onDispatchTap( fx , fy , 1 , 2 );
			#end
		}

		/**
		* Two Fingers Tap Callback
		* 
		* @private
		* @param	fx : Location X of the Tap ( Float )
		* @param	fy : Location Y of the Tap ( Float )
		* @return	void
		*/
		private function _onTwixCallback( fx : Float , fy : Float ) : Void{
			#if iphone
			var res = _convertToGl( fx , fy );
			_onDispatchTap( res.x , res.y , 2 , 1 );
			#else
			_onDispatchTap( fx , fy , 2 , 1 );
			#end
		}

		#end

		#if iphone

		/**
		* Convert the coordinates for openGL stage coordinates
		* Warning : Seems buggy
		*
		* @private
		* @param 	f : Position to convert ( float )
		* @return	res ( FPoint )
		*/
		private function _convertToGl( fx : Float , fy : Float ) : FPoint{
			
			_fTmp.x = fx;
			_fTmp.y = fy;
			var ori : Int = hyp_touch_get_orientation( );
			
			switch ( ori ) {
				
				case Stage.OrientationPortrait:
					_fTmp.x = nme.Lib.current.stage.stageWidth - fy;
					_fTmp.y = fx;

				case Stage.OrientationPortraitUpsideDown:
					_fTmp.x = fy;
					_fTmp.y = nme.Lib.current.stage.stageHeight - fx;

				case Stage.OrientationLandscapeLeft:
					_fTmp.x = nme.Lib.current.stage.stageWidth - fy;
					_fTmp.y = fx;

				case Stage.OrientationLandscapeRight:
					_fTmp.x = fy;
					_fTmp.y = nme.Lib.current.stage.stageHeight - fx;
				
				case Stage.OrientationFaceDown:
					_fTmp.x = nme.Lib.current.stage.stageWidth - fy;
					_fTmp.y = fx;

				case Stage.OrientationFaceUp:
					_fTmp.x = nme.Lib.current.stage.stageWidth - fy;
					_fTmp.y = fx;
					
			}
			return _fTmp;
		}

		#end

		/**
		* Dispatch an Tap Event at the specified position, fingers and taps count
		* 
		* @private
		* @param	fx      : Position X of the Tap Event ( Float )
		* @param	fy      : Position Y of the Tap Event ( Float )
		* @param	fingers : Tap fingers count ( Int )
		* @param	taps    : Taps count ( Int )
		* @return	void
		*/
		private function _onDispatchTap( fx : Float , fy : Float , fingers : Int , taps : Int = 1 ) : Void{
			
			if( fingers == 1 ){

				if( taps == 2 )
					_dispatch( new GestureTapEvent( GestureTapEvent.DOUBLE_TAP , fx , fy ) );
				else if( taps == 1 )
					_dispatch( new GestureTapEvent( GestureTapEvent.TAP , fx , fy ) );				

			}else if( taps == 1 && fingers == 2 )
				_dispatch( new GestureTapEvent( GestureTapEvent.TWO_FINGERS_TAP , fx , fy ) );
			
		}

		/**
		* Dispatch a gesture & check if there is still listener for this event
		* If not more listener is registered, the Gesture is disable on the native side.
		* 
		* @private
		* @param	e : Event to be Tested ( Event )
		* @return	void
		*/
		private function _dispatch( e : Event ) : Void{
			
			_disable( e.type );
			if( hasEventListener( e.type ) )
				dispatchEvent( e );
						
		}



		/**
		* Dispatch an Swipe Event for the specified direction
		* 
		* @private
		* @param	direction : Direction of the swipe ( Int )
		* @return	void
		*/
		private function _onDispatchSwipe( direction : Int ) : Void{
			//trace('_onDispatchSwipe ::: '+direction);
			_disable( GestureSwipeEvent.SWIPE );
			dispatchEvent( new GestureSwipeEvent( direction ) );
		}

		/**
		* Dispatch an Rotation Event
		* 
		* @private
		* @param	fRotation : Rotation gesture ( Float )
		* @param	fVelocity : Rotation velocity ( Float )
		* @return	void
		*/
		private function _onDispatchRotation( fRotation : Float , fVelocity : Float ) : Void{
			_disable( GestureRotationEvent.ROTATE );
			dispatchEvent( new GestureRotationEvent( fRotation , fVelocity ) );
		}

		/**
		* Dispatch an Pan Event
		* 
		* @private
		* @param	fx : X offset 	( Float )
		* @param	fy : Y offset 	( Float )
		* @param	vx : X velocity ( Float )
		* @param	vy : Y velocity ( Float )
		* @return	void
		*/
		#if android
		private function _onDispatchPan( iPhase : Int , tx : Float , ty : Float , vx : Float , vy : Float , fCenterX : Float , fCenterY : Float , fPressure : Float ) : Void{
		#else
		private function _onDispatchPan( iPhase : Int , tx : Float , ty : Float , vx : Float , vy : Float , fCenterX : Float , fCenterY : Float ) : Void{
		#end
			_disable( GesturePanEvent.PAN );
			
			#if android
			var ev = new GesturePanEvent( -tx , -ty , vx / nme.Lib.current.stage.stageWidth , vy / nme.Lib.current.stage.stageHeight , fCenterX , fCenterY);
				ev.pressure = fPressure;
			#else
			var ev = new GesturePanEvent( tx , ty , vx / nme.Lib.current.stage.stageWidth , vy / nme.Lib.current.stage.stageHeight , fCenterX , fCenterY);
			#end
				ev.phase = iPhase;
			dispatchEvent( ev );
		}

		/**
		* Dispatch an Pinch Event
		* 
		* @private
		* @param 	fScale    : Pinch Scale Value ( Float )
		* @param 	fVelocity : Velocity of the pinch ( Float )
		* @return	void
		*/
		private function _onDispatchPinch( fScale : Float , fVelocity : Float ) : Void{
			
			try{ 
				_disable( GesturePinchEvent.PINCH );
				dispatchEvent( new GesturePinchEvent( fScale , fVelocity ) );
			}catch( e : Error ){
			
			}
		}

		/**
		* If not more listener is registered, the Gesture is disable on the native side.
		* 
		* @private
		* @param	e : Event to be Tested ( Event )
		* @return	void
		*/
		private function _disable( type : String ) : Void{

			//We disable the taps gestures only if all taps gestures are disabled
			if( type == GestureTapEvent.TAP || type == GestureTapEvent.DOUBLE_TAP || type == GestureTapEvent.TWO_FINGERS_TAP )
				if( hasEventListener( GestureTapEvent.TAP ) || hasEventListener( GestureTapEvent.DOUBLE_TAP ) || hasEventListener( GestureTapEvent.TWO_FINGERS_TAP ) )
					return;

			if( !hasEventListener( type ) ){
				#if iphone
				hyp_touch_deactivate( getCode( type ) );
				#end

				#if android
				hyp_touch_toggle( getCode( type ) , false );
				#end
			}
		}

	// -------o misc
		
		/**
		* Singleton instance of the HyperTouch 
		* 
		* @public
		* @return	singleton instance of the Class
		*/
		static public function getInstance( ) : HyperTouch {
			if( __instance == null )
				__instance = new HyperTouch( );

			return __instance;
		}

		private static var __instance : HyperTouch = null;
}


#end

///!\ DO NOT CHANGE THE ORDER /!\
enum Gestures{
	TAP;
	DOUBLE_TAP;
	TWO_FINGERS_TAP;
	PAN;
	PINCH;
	ROTATE;
	SWIPE;
	LONG_PRESS;
}

typedef FPoint={
	public var x : Float;
	public var y : Float;
}