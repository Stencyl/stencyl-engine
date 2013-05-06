package fr.hyperfiction.events;

import nme.events.Event;

/**
 * ...
 * @author shoe[box]
 */

class GesturePinchEvent extends Event{

	public var scale( default , default ) : Float;
	public var velocity( default , default ) : Float;

	public static inline var PINCH : String = 'PINCH';
	
	// -------o constructor
		
		/**
		* constructor
		*
		* @param 	fScale    : Pinch Scale Value ( Float )
		* @param 	fVelocity : Velocity of the pinch ( Float )
		* @return	void
		*/
		public function new( fScale : Float , fVelocity : Float ) {
			super( PINCH );
			this.scale = fScale;
			this.velocity = fVelocity;
		}
	
	// -------o public
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		override public function toString( ) : String {
			return '[ '+PINCH+' scale : '+scale+' velocity : '+velocity+' ]';
		}

	// -------o protected
	
	// -------o misc
	
}