package fr.hyperfiction.events;

import nme.events.Event;

/**
 * ...
 * @author shoe[box]
 */

class GestureRotationEvent extends Event{

	public var rotation ( default , default ) : Float;
	public var velocity ( default , default ) : Float;

	public static inline var ROTATE : String = 'ROTATE';

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public function new( rotation : Float , velocity : Float ) {
			super( ROTATE );
			this.rotation = rotation;
			this.velocity = velocity;
		}
	
	// -------o public

		/**
		* 
		* 
		* @public
		* @return	void
		*/
		override public function toString( ) : String {
			return '[ '+ROTATE+' velocity : '+velocity+' rotation : '+rotation +']';
		}

	// -------o protected

	// -------o misc
	
}