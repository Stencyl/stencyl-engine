package fr.hyperfiction.events;

import nme.events.Event;

/**
 * ...
 * @author shoe[box]
 */

class GesturePanEvent extends Event{
	
	public var phase		: Int;
	public var centerX		: Float;
	public var centerY		: Float;
	public var offsetX		: Float;
	public var offsetY		: Float;
	public var velocityX	: Float;
	public var velocityY	: Float;

	#if android
	public var pressure : Float;
	#end
	
	public static inline var PAN : String = 'PAN';

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public function new( fx : Float , fy : Float , vx : Float , vy : Float , cx : Float , cy : Float ) {
			super( PAN );
			this.offsetX	= fx;
			this.offsetY	= fy;
			this.velocityX	= vx;
			this.velocityY	= vy;	
			this.centerX	= cx;		
			this.centerY	= cy;		
		}
	
	// -------o public
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		override public function toString( ) : String {
			return '[ '+PAN+' offsetX : '+offsetX+' offsetY : '+offsetY+' phase : '+phase+']';
		}

	// -------o protected
	
	// -------o misc
	
}