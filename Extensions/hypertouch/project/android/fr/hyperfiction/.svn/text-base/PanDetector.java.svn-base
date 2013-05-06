package fr.hyperfiction;

import android.util.Log;
import android.view.GestureDetector.SimpleOnGestureListener;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.Toast;
import fr.hyperfiction.HyperTouch;
import org.haxe.nme.GameActivity;

/**
 * ...
 * @author shoe[box]
 */

class PanDetector extends GestureDetector.SimpleOnGestureListener{

	public static String TAG = "HyperTouch :: PanDetector";

	private VelocityTracker mVelocityTracker;
	private Boolean _bScrolling;
	private Boolean _recycleVelocityTracker;

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public PanDetector() {
			trace("constructor");
			_bScrolling = false;
			_recycleVelocityTracker = false;
		}
	
	// -------o public
		/**
		* <code>SimpleOnGestureListener</code> onTouch Generic Method
		* 
		* @public
		* @return	void
		*/
		public boolean onTouchEvent( final MotionEvent ev) {

			int i = 0;			
			int action = ev.getAction();
			 switch(action) {
	            case MotionEvent.ACTION_DOWN:
	            	if(mVelocityTracker == null)
	                    mVelocityTracker = VelocityTracker.obtain();
	                else
	                    mVelocityTracker.clear();
	             	   mVelocityTracker.addMovement( ev );
	                break;

	            case MotionEvent.ACTION_MOVE:
	            	if(mVelocityTracker == null)
	                    mVelocityTracker = VelocityTracker.obtain();
	               		mVelocityTracker.addMovement( ev );
	                	mVelocityTracker.computeCurrentVelocity( 1000 );	               
	                break;

	            case MotionEvent.ACTION_UP:
	            case MotionEvent.ACTION_CANCEL:
	            	mVelocityTracker.recycle();
	                if( _bScrolling && ev.getPointerCount( ) == 1 ){
	                	_endScroll( ev );
	                }
	                _recycleVelocityTracker = true;
					//Nothing can use mVelocityTracker after it gets recycled
					// mVelocityTracker.recycle();
	                break;
	        }
	        if (_recycleVelocityTracker){
				_recycleVelocityTracker = false;
				 mVelocityTracker.recycle();
			}
			return false;
		}

		/**
		* 
		* 
		* @private
		* @return	void
		*/
		private void _endScroll( MotionEvent ev ){
			_bScrolling = false;
			_emitScroll( 2 , 0 , 0 , mVelocityTracker.getXVelocity( ) , mVelocityTracker.getYVelocity( ) , ev.getX() , ev.getY( ) , ev.getPressure( 0 ) );
		}

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		@Override
		public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {  

			if( e2.getPointerCount( ) != 1 )
				return false;

			int iPhase = 1;
			if( _bScrolling == null )
					_bScrolling = false;

			if( !_bScrolling ){
				_bScrolling = true;
				iPhase = 0;
			}

			_emitScroll( 
							iPhase , 
							distanceX , distanceY , 
							0,0,//mVelocityTracker.getXVelocity( ) , mVelocityTracker.getYVelocity( ) , 
							e2.getX() , e2.getY( ) , 
							e2.getPressure( 0 ) 
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
		private void _emitScroll( 
									final int phase , 
									final float dx , final float dy , 
									final float vx , final float vy , 
									final float cx , final float cy , 
									final float pressure 
								){
			
			HyperTouch.mSurface.queueEvent(
				new Runnable(){
	                public void run() { 
						HyperTouch.onPan( 
											phase,
											dx , dy,
											vx , vy,
											cx , cy,
											pressure
										);
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