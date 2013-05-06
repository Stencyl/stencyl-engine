package fr.hyperfiction.events;

import nme.events.Event;

/**
 * ...
 * @author shoe[box]
 */

class GestureTapEvent extends Event{

	public var stageX : Float;
	public var stageY : Float;

	public static inline var DOUBLE_TAP      : String = 'DOUBLE_TAP';
	public static inline var TAP             : String = 'TAP';
	public static inline var TWO_FINGERS_TAP : String = 'TWO_FINGERS_TAP';

	// -------o constructor
		
		/**
		* constructor
		*
		* @param	
		* @return	void
		*/
		public function new( type : String , fx : Float , fy : Float ) {
			super( type );
			this.stageX = fx;
			this.stageY = fy;
		}
	
	// -------o public
		
		/**
		* 
		* 
		* @public
		* @return	void
		*/
		override public function toString( ) : String {
			return '[ '+type+' at position x : '+stageX+' y : '+stageY+']';
		}

	// -------o protected
	
	// -------o misc
	
}