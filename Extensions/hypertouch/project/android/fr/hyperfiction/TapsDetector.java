package fr.hyperfiction;

import android.util.Log;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import fr.hyperfiction.HyperTouch;
import org.haxe.nme.GameActivity;

/**
 * ...
 * @author shoe[box]
 */

class TapsDetector extends GestureDetector.SimpleOnGestureListener{

	public static String TAG = "HyperTouch :: TapsDetector";

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public TapsDetector() {
			
		}
	
	// -------o public
		
		/**
		* <code>SimpleOnGestureListener</code> onTouch Generic Method
		* 
		* @public
		* @return	void
		*/
		public boolean onTouchEvent( final MotionEvent ev) {
			boolean b = false;
			switch (ev.getAction( ) & MotionEvent.ACTION_MASK) {
				case MotionEvent.ACTION_POINTER_DOWN:
					if( ev.getPointerCount( ) == 2 ){
						_twix( ev );
						b = true;
					}
					break;
			}
			return b;
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public boolean onDoubleTap( MotionEvent ev ){
			final float x = ev.getX( );
           	final float y = ev.getY( );
			HyperTouch.mSurface.queueEvent(
				new Runnable(){
	                public void run() { 
						HyperTouch.onDoubleTap( x , y );
	                }
	            }
			);
			return true;	
		}

		/**
		* Listener of the Tap Gesture
		* 
		* @public
		* @param	e : Gesture ( MotionEvent )
		* @return	false
		*/
		public boolean onSingleTapConfirmed ( MotionEvent ev ) {
			final float x = ev.getX( );
           	final float y = ev.getY( );
			HyperTouch.mSurface.queueEvent(
				new Runnable(){
	                public void run() { 
						HyperTouch.onTap( x , y );
	                }
	            }
			);
			
			return true;
		}

	// -------o protected
		
		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private void _twix( MotionEvent ev ){
			final float x = ev.getX( );
           	final float y = ev.getY( );
			HyperTouch.mSurface.queueEvent(
				new Runnable(){
	                public void run() { 
						HyperTouch.onTwix( x , y );
	                }
	            }
			);
		}

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
}	