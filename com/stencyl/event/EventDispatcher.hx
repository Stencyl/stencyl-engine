package com.stencyl.event;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.PositionTools;

class EventDispatcher
{
    /**
		Dispatches a new event callback to all listeners. The signature for the
		`dispatch` method depends upon the type of the `Event`. For example, an
		`Event` of type `Int->Int->Void` will create a `dispatch` method that
		takes two `Int` arguments, like `dispatch (1, 2);`
	**/
	macro public static function dispatch<T>(event:ExprOf<Event<T>>, args:Array<Expr>):Expr
	{
		//var posInfos = PositionTools.toLocation(Context.currentPos());
		//var posInfos = Context.getPosInfos(Context.currentPos());

		@:pos(Context.currentPos())
		return macro
		{
			@:privateAccess
			if($event.length > 0)
			{
				$event._dispatchIndex = 0;
				while($event._dispatchIndex < $event.length)
				{
					#if debug_event_dispatch
					var posinfo = $event.posInfos[$event._dispatchIndex];
					com.stencyl.utils.Log.verbose("Call event from: " + posinfo.fileName + ":" + posinfo.lineNumber);
					#end
					try
					{
						$event.listeners[$event._dispatchIndex]($a{args});
					}
					catch(e:Dynamic)
					{
						com.stencyl.utils.Log.error(e + com.stencyl.utils.Utils.printExceptionstackIfAvailable());
					}
					++$event._dispatchIndex;
				}
			}
		}
	}
}