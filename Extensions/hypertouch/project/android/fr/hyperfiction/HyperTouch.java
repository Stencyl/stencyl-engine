package fr.hyperfiction;

import android.opengl.GLSurfaceView;
import android.util.Log;
import android.view.GestureDetector;
import android.view.ScaleGestureDetector;
import android.view.MotionEvent;
import android.view.View;
import fr.hyperfiction.SwipeDetector;
import fr.hyperfiction.TapsDetector;
import org.haxe.nme.GameActivity;

public class HyperTouch implements View.OnTouchListener{

	//
		private View mViewNME;
		public static GLSurfaceView mSurface;
		private PanDetector mPanDetector;
		private SwipeDetector mSwipeDetector;
		private TapsDetector mTapsDetector;
		private PinchDetector mPinchDetector;

	//Gestures
		static public GestureDetector oSwipeGesture;
		static public GestureDetector oPanGesture;
		static public GestureDetector oTapGesture;
		static public ScaleGestureDetector oPinchGesture;

	//Gestures Codes
	   	final static int GESTURE_TAP		= 0;
		final static int GESTURE_TAP2		= 1;
		final static int GESTURE_TWIX		= 2;
		final static int GESTURE_PAN		= 3;
		final static int GESTURE_PINCH		= 4;
		final static int GESTURE_ROT		= 5;
		final static int GESTURE_SWIPE		= 6;
		final static int GESTURE_LONG_PRESS	= 7;

	//JNI
		static public native void onTap( float fx , float fy );
		static public native void onTwix( float fx , float fy );
		static public native void onDoubleTap( float fx , float fy );
		static public native void onPan( int phase , float fx , float fy , float vx , float vy , float cx , float cy , float pressure );
		static public native void onPinch( float scale );
		static public native void onSwipe( int dir );
		
		static {
			System.loadLibrary( "hypertouch" ); 
		}

	//
		public static String TAG = "HyperTouch";

	// -------o constructor

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public void HyperTouch( ){
			Log.i( TAG , "constructor");
		}

	// -------o public

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public void init( ){
			Log.i( TAG , "init ::: " );		
			mViewNME  = GameActivity.getInstance( ).getCurrentFocus( );
			mViewNME.setOnTouchListener( this );	

			mSwipeDetector = new SwipeDetector( );
			mPanDetector   = new PanDetector( );
			mTapsDetector  = new TapsDetector( );
			mPinchDetector  = new PinchDetector( );

			mSurface = ( GLSurfaceView ) mViewNME;
		}

		/**
		* <code>SimpleOnGestureListener</code> onTouch Generic Method
		* 
		* @public
		* @return	void
		*/
		public boolean onTouch( View v , final MotionEvent ev) {
			
			boolean b = true;
			if( oSwipeGesture != null )
				b = oSwipeGesture.onTouchEvent( ev );
			
			if( oPanGesture != null && !b ){
				oPanGesture.onTouchEvent( ev );
				b = mPanDetector.onTouchEvent( ev );
			}
			
			if( oPinchGesture!= null && !b )
				b = oPinchGesture.onTouchEvent( ev );

			if( oTapGesture != null )
				oTapGesture.onTouchEvent( ev );
			

			return b;
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public void toggleGesture( int code , final boolean b ){
			
			switch( code ){

				case GESTURE_SWIPE:
					if( oSwipeGesture == null && b ){
						GameActivity.getInstance( ).mHandler.post(
							new Runnable(){
									@Override public void run(){
										HyperTouch.oSwipeGesture = new GestureDetector( 
																						GameActivity.getInstance( ) , 
																						mSwipeDetector
																					 );
									}
						});
					}else
						if( !b )
								oSwipeGesture = null;
					break;

				case GESTURE_PAN:
					if( oPanGesture == null && b ){
						GameActivity.getInstance( ).mHandler.post(
							new Runnable(){
									@Override public void run(){
										HyperTouch.oPanGesture = new GestureDetector( 
																						GameActivity.getInstance( ) , 
																						mPanDetector
																					 );
									}
						});
					}else 
						if( !b )
								oPanGesture = null;
					break;

				case GESTURE_TAP:
			
					if( oTapGesture == null && b ){
						GameActivity.getInstance( ).mHandler.post(
							new Runnable(){
									@Override public void run(){
										HyperTouch.oTapGesture = new GestureDetector( 
																						GameActivity.getInstance( ) , 
																						mTapsDetector
																					 );
									}
						});
					}else 
						if( !b )
								oTapGesture = null;
					break;

				case GESTURE_PINCH:
					if( oPinchGesture == null && b ){
						GameActivity.getInstance( ).mHandler.post(
							new Runnable(){
									@Override public void run(){
										HyperTouch.oPinchGesture = new ScaleGestureDetector( 
																						GameActivity.getInstance( ) , 
																						mPinchDetector
																					 );
									}
						});
					}else 
						if( !b )
								oPinchGesture = null;
					break;
			}
		}

	// -------o private


	// -------o misc

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		static public void trace( String s ){
			Log.i( TAG , s );
		}

		public static void HyperTouch_init( ){
			Log.i( TAG , "HyperTouch_init ::: ");
			__instance = new HyperTouch( );
			__instance.init( );	
		}

		public static void HyperTouch_toggle( int code , boolean b ){
			getInstance( ).toggleGesture( code , b );
		}

		public static HyperTouch getInstance( ){

			if( __instance == null )
				__instance = new HyperTouch( );

			return __instance;
		}
		static private HyperTouch __instance = null;
}