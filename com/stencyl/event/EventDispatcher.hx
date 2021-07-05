package com.stencyl.event;

import haxe.macro.Context;
import haxe.macro.Expr;

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
		@:pos(Context.currentPos())
		return macro
		{
			if($event.length > 0)
			{
				var i = 0;
				while(i < $event.length)
				{
					try
					{
						$event.listeners[i]($a{args});
					}
					catch(e:String)
					{
						trace(e + com.stencyl.utils.Utils.printExceptionstackIfAvailable());
					}
					++i;
				}
			}
		}
	}
}