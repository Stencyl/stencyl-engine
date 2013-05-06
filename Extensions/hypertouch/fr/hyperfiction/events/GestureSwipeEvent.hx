package fr.hyperfiction.events;

import nme.events.Event;

/**
 * ...
 * @author shoe[box]
 */

class GestureSwipeEvent extends Event{

	public var direction( default , default ) : Int;

	public static inline var SWIPE : String = 'SWIPE';

	public static inline var DIRECTION_RIGHT : Int = 1;
	public static inline var DIRECTION_LEFT  : Int = 2;
	public static inline var DIRECTION_UP    : Int = 4;
	public static inline var DIRECTION_DOWN  : Int = 8;
	
	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public function new( direction : Int ) {
			super( SWIPE );
			this.direction = direction;
		}
	
	// -------o public
				
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		override public function toString( ) : String {
			return '[ '+SWIPE+' direction : '+direction+' ]';
		}

	// -------o protected
	
	// -------o misc
	
}