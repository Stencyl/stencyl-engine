package fr.hyperfiction;

import android.util.Log;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import android.widget.Toast;
import fr.hyperfiction.HyperTouch;
import org.haxe.nme.GameActivity;

/**
 * ...
 * @author shoe[box]
 */

class SwipeDetector extends GestureDetector.SimpleOnGestureListener{

	public static String TAG = "HyperTouch :: SwipeDetector";

	//Perhaps not the better way to detect a Swipe in Android
		private static final int SWIPE_MIN_DISTANCE = 120;
		private static final int SWIPE_MAX_OFF_PATH = 250;
		private static final int SWIPE_THRESHOLD_VELOCITY = 200;

	//Directions codes for Haxe Callback
			final static int SWIPE_DIRECTION_RIGHT = 1;
			final static int SWIPE_DIRECTION_LEFT  = 2;
			final static int SWIPE_DIRECTION_UP    = 4;
			final static int SWIPE_DIRECTION_DOWN  = 8;

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public void SwipeDetector() {
			
		}
	
	// -------o public
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {  
			boolean b = false;
			try {
				
				if (Math.abs(e1.getY() - e2.getY()) > SWIPE_MAX_OFF_PATH)
					return false;

				// right to left swipe
				if (e1.getX() - e2.getX() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
					Log.i(TAG, "Left Swipe");
					_swipe( SWIPE_DIRECTION_LEFT );
					b = true;
				} else if (e2.getX() - e1.getX() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
					Log.i(TAG, "Right Swipe");
					_swipe( SWIPE_DIRECTION_RIGHT );
					b = true;
				} else if (e1.getY() - e2.getY() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
					Log.i(TAG, "Swipe up");
					_swipe( SWIPE_DIRECTION_UP );
					b = true;
				} else if (e2.getY() - e1.getY() > SWIPE_MIN_DISTANCE
						&& Math.abs(velocityX) > SWIPE_THRESHOLD_VELOCITY) {
					Log.i(TAG, "Swipe down");
					_swipe( SWIPE_DIRECTION_DOWN );
					b = true;
				}

			} catch (Exception e) {
				// nothing
			}
			return b;
		}

	// -------o protected
		
		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private void _swipe( final int dir ){
			Log.i( TAG , "onSwipe ::: "+dir);
			HyperTouch.mSurface.queueEvent(
				new Runnable(){
	                public void run() { 
						HyperTouch.onSwipe( dir );
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