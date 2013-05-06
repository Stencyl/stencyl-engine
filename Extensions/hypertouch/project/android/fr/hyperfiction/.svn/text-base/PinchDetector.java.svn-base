package fr.hyperfiction;

import android.util.Log;
import android.view.ScaleGestureDetector.SimpleOnScaleGestureListener;
import android.view.ScaleGestureDetector;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import android.widget.Toast;
import fr.hyperfiction.HyperTouch;
import org.haxe.nme.GameActivity;

/**
 * ...
 * @author shoe[box]
 */

class PinchDetector extends ScaleGestureDetector.SimpleOnScaleGestureListener{

	public static String TAG = "HyperTouch :: PinchDetector";

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public PinchDetector() {
			
		}
	
	// -------o public
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		public boolean onScale( ScaleGestureDetector detector) {
			final float scl = detector.getScaleFactor( );
			HyperTouch.getInstance( ).mSurface.queueEvent(
					new Runnable(){
		                public void run() { 
		                	HyperTouch.onPinch( scl );
		                }
		            }
				);
			return false;
		}


	// -------o protected
		
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