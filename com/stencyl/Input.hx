package com.stencyl;

import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.display.DisplayObject;
import nme.geom.Point;

#if !js
import nme.events.TouchEvent;
import nme.ui.Multitouch;
#end

#if cpp
import nme.ui.Accelerometer;
#end

import nme.ui.Keyboard;
import nme.Lib;


class Input
{

	public static var keyString:String = "";

	public static var lastEvent:KeyboardEvent;
	public static var lastKey:Int;
	
	public static var mouseX:Float = 0;
	public static var mouseY:Float = 0;

	public static var mouseDown:Bool;
	public static var mouseUp:Bool;
	public static var mousePressed:Bool;
	public static var mouseReleased:Bool;
	public static var mouseWheel:Bool;
	
	public static var accelX:Float;
	public static var accelY:Float;
	public static var accelZ:Float;
	
	#if !js
	public static var multiTouchEnabled:Bool;
	public static var multiTouchPoints:Map<String,TouchEvent>;
	#end
	
	public static var numTouches:Int;

	private static var swipeDirection:Int;
	public static var swipedUp:Bool;
	public static var swipedDown:Bool;
	public static var swipedLeft:Bool;
	public static var swipedRight:Bool;

	/**
	 * Returns the control->key map.
	 */
	public static function getControlMap():Map<String,Array<Int>>
	{
		return _control;
	}
	
	/**
	 * Defines a new input.
	 * @param	name		String to map the input to.
	 * @param	...keys		The keys to use for the Input.
	 */
	public static function define(name:String, keys:Array<Int>)
	{
		_control.set(name, keys);
	}

	/**
	 * If the input or key is held down.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function check(input:Dynamic):Bool
	{
		if(Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input);
			
			if(v == null)
			{
				//trace("No control selected for a control attribute");
				return false;
			}
			
			var i:Int = v.length;
			
			while(i-- > 0)
			{
				if(v[i] < 0)
				{
					if(_keyNum > 0) 
					{
						return true;
					}
					
					continue;
				}
				
				if(_key[v[i]]) 
				{
					return true;
				}
			}
			
			return false;
		}
		
		return input < 0 ? _keyNum > 0 : _key[input];
	}

	/**
	 * If the input or key was pressed this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function pressed(input:Dynamic):Bool
	{
		if(Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input);
			
			if(v == null)
			{
				//trace("No control selected for a control attribute");
				return false;
			}
			
			var i:Int = v.length;
			
			while(i-- > 0)
			{
				if((v[i] < 0) ? _pressNum != 0 : indexOf(_press, v[i]) >= 0) 
				{
					return true;
				}
			}
			
			return false;
		}
		
		return (input < 0) ? _pressNum != 0 : indexOf(_press, input) >= 0;
	}

	/**
	 * If the input or key was released this frame.
	 * @param	input		An input name or key to check for.
	 * @return	True or false.
	 */
	public static function released(input:Dynamic):Bool
	{
		if(Std.is(input, String))
		{
			var v:Array<Int> = _control.get(input);
			
			if(v == null)
			{
				//trace("No control selected for a control attribute");
				return false;
			}
			
			var i:Int = v.length;
			
			while(i-- > 0)
			{
				if((v[i] < 0) ? _releaseNum != 0 : indexOf(_release, v[i]) >= 0) 
				{
					return true;
				}
			}
			
			return false;
		}
		
		return (input < 0) ? _releaseNum != 0 : indexOf(_release, input) >= 0;
	}

	/**
	 * Copy of Lambda.indexOf for speed/memory reasons
	 * @param	a array to use
	 * @param	v value to find index of
	 * @return	index of value in the array
	 */
	private static function indexOf(a:Array<Int>, v:Int):Int
	{
		var i = 0;
		
		for(v2 in a) 
		{
			if(v == v2)
			{
				return i;
			}
			
			i++;
		}
		
		return -1;
	}
	
	public static function enableSwipeDetection()
	{
		#if(mobile && !air)
		//var gestures = HyperTouch.getInstance();
		//gestures.addEventListener(GestureSwipeEvent.SWIPE, onSwipe, false);
		#end
	}
	
	public static function disableSwipeDetection()
	{
		#if(mobile && !air)
		//var gestures = HyperTouch.getInstance();
		//gestures.removeEventListener(GestureSwipeEvent.SWIPE, onSwipe, false);
		#end
	}

	public static function enable()
	{
		if(!_enabled && Engine.stage != null)
		{
			Engine.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
			Engine.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,  2);
			Engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 2);
			Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false,  2);
			Engine.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel, false, 2);
			
			//Disable default behavior for Android Back Button
			#if(mobile && android)
			if(scripts.MyAssets.disableBackButton)
			{
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(event) 
				{
				   	lastEvent = event;
				   
				   	if(lastEvent.keyCode == 27) 
				   	{
					  	lastEvent.stopImmediatePropagation();
					  	lastEvent.stopPropagation();
				   	}
				});
				
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function(event) 
				{
					lastEvent = event;

				   	if(lastEvent.keyCode == 27) 
				   	{
					  	lastEvent.stopImmediatePropagation();
					  	lastEvent.stopPropagation();
				   	}
				});
			}
			#end
			
			#if !js
			multiTouchEnabled = Multitouch.supportsTouchEvents;
			
			if(multiTouchEnabled)
	        {
	        	multiTouchPoints = new Map<String,TouchEvent>();
	        	Multitouch.inputMode = nme.ui.MultitouchInputMode.TOUCH_POINT;
	        	Engine.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
	        	Engine.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
         		Engine.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
	        }
	        #end
	        
			var roxAgent = new RoxGestureAgent(Engine.engine.root, RoxGestureAgent.GESTURE);
			Engine.engine.root.addEventListener(RoxGestureEvent.GESTURE_SWIPE, onSwipe);
			
			swipeDirection = -1;
			swipedLeft = false;
			swipedRight = false;
			swipedUp = false;
			swipedDown = false;
	        
	        mouseX = 0;
	        mouseY = 0;
	        accelX = 0;
	        accelY = 0;
	        accelZ = 0;
	        numTouches = 0;
	        _enabled = true;
		}
	}
	
	private static function onSwipe(e:RoxGestureEvent):Void
	{
		var pt = cast(e.extra, Point);
        
        if(Math.abs(pt.x) <= Math.abs(pt.y))
        {
        	//Up
        	if(pt.y <= 0)
        	{
        		swipeDirection = 2;
        	}
        	
        	//Down
        	else
        	{
        		swipeDirection = 3;
        	}
        }
        
        else if(Math.abs(pt.x) > Math.abs(pt.y))
        {
        	//Left
        	if(pt.x <= 0)
        	{
        		swipeDirection = 0;
        	}
        	
        	//Right
        	else
        	{
        		swipeDirection = 1;
        	}
        }
	}

	public static function update()
	{
		swipedLeft = false;
		swipedRight = false;
		swipedUp = false;
		swipedDown = false;
		
		if(swipeDirection > -1)
		{
			switch(swipeDirection)
			{
				case 0:
					swipedLeft = true;
				case 1:
					swipedRight = true;
				case 2:
					swipedUp = true;
				case 3:
					swipedDown = true;
			}
			
			if(Engine.engine.whenSwipedListeners != null)
			{
				Engine.invokeListeners(Engine.engine.whenSwipedListeners);
			}
			
			swipeDirection = -1;
		}
		
		#if cpp
		if(nme.sensors.Accelerometer.isSupported)
		{
			var data = Accelerometer.get();
			
			accelX = data.x;
			accelY = data.y;
			accelZ = data.z;
		}
		#end
		
		//Mouse is always in absolute coordinates, so adjust when screen size != game size
		mouseX = (Engine.stage.mouseX - Engine.screenOffsetX) / Engine.screenScaleX;
		mouseY = (Engine.stage.mouseY - Engine.screenOffsetY) / Engine.screenScaleY;
	
		while (_pressNum-- > -1) _press[_pressNum] = -1;
		_pressNum = 0;
		while (_releaseNum-- > -1) _release[_releaseNum] = -1;
		_releaseNum = 0;

		if(mousePressed) 
		{
			mousePressed = false;
		}
		
		if(mouseReleased) 
		{
			mouseReleased = false;
		}
	}
	
	public static function simulateKeyPress(key:String)
	{
		var v:Int = _control.get(key)[0];
		
		Input.onKeyDown(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, v, v));
		
		//Due to order of execution, events will never get thrown since the
		//pressed/released flag is reset before the event checker sees it. So
		//throw the event immediately.
		var listeners = Engine.engine.whenKeyPressedListeners.get(key);
		
		if(listeners != null)
		{
			Engine.invokeListeners3(listeners, true, false);
		}
	}
	
	public static function simulateKeyRelease(key:String)
	{
		var v:Int = _control.get(key)[0];
		
		Input.onKeyUp(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, v, v));
		
		//Due to order of execution, events will never get thrown since the
		//pressed/released flag is reset before the event checker sees it. So
		//throw the event immediately.
		var listeners = Engine.engine.whenKeyPressedListeners.get(key);
		
		if(listeners != null)
		{
			Engine.invokeListeners3(listeners, false, true);
		}
	}

	public static function onKeyDown(e:KeyboardEvent = null)
	{
		var code:Int = lastKey = e.keyCode;
		
		if(code == Key.BACKSPACE) 
		{
			keyString = keyString.substr(0, keyString.length - 1);
		}
		
		else if ((code > 47 && code < 58) || (code > 64 && code < 91) || code == 32)
		{
			if (keyString.length > kKeyStringMax) keyString = keyString.substr(1);
			var char:String = String.fromCharCode(code);
			#if flash
			if (e.shiftKey || Keyboard.capsLock) char = char.toUpperCase();
			else char = char.toLowerCase();
			#end
			keyString += char;
		}

		if(!_key[code])
		{
			_key[code] = true;
			_keyNum++;
			_press[_pressNum++] = code;
		}
		
		Engine.invokeListeners2(Engine.engine.whenAnyKeyPressedListeners, e);
	}

	public static function onKeyUp(e:KeyboardEvent = null)
	{
		var code:Int = e.keyCode;
		
		if(_key[code])
		{
			_key[code] = false;
			_keyNum--;
			_release[_releaseNum++] = code;
		}
		
		Engine.invokeListeners2(Engine.engine.whenAnyKeyReleasedListeners, e);
	}

	private static function onMouseDown(e:MouseEvent)
	{
		//On mobile, mouse position isn't always updated till you touch, so we need to update immediately
		//so that events are properly notified
		#if mobile
		mouseX = (Engine.stage.mouseX - Engine.screenOffsetX) / Engine.screenScaleX;
		mouseY = (Engine.stage.mouseY - Engine.screenOffsetY) / Engine.screenScaleY;
		#end
		
		if(!mouseDown)
		{
			mouseDown = true;
			mouseUp = false;
			mousePressed = true;
		}
	}

	private static function onMouseUp(e:MouseEvent)
	{
		//On mobile, mouse position isn't always updated till you touch, so we need to update immediately
		//so that events are properly notified
		#if mobile
		mouseX = (Engine.stage.mouseX - Engine.screenOffsetX) / Engine.screenScaleX;
		mouseY = (Engine.stage.mouseY - Engine.screenOffsetY) / Engine.screenScaleY;
		#end
		
		mouseDown = false;
		mouseUp = true;
		mouseReleased = true;
	}

	private static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		_mouseWheelDelta = e.delta;
	}
	
	#if !js
	private static function onTouchBegin(e:TouchEvent)
	{
		Engine.invokeListeners2(Engine.engine.whenMTStartListeners, e);
	
		multiTouchPoints.set(Std.string(e.touchPointID), e);
		numTouches++;
	}
	
	private static function onTouchMove(e:TouchEvent)
	{
		Engine.invokeListeners2(Engine.engine.whenMTDragListeners, e);
	
		multiTouchPoints.set(Std.string(e.touchPointID), e);
	}
	
	private static function onTouchEnd(e:TouchEvent)
	{
		Engine.invokeListeners2(Engine.engine.whenMTEndListeners, e);
		
		multiTouchPoints.remove(Std.string(e.touchPointID));
		numTouches--;
	}
	#end

	private static inline var kKeyStringMax = 100;

	private static var _enabled:Bool = false;
	private static var _key:Array<Bool> = new Array<Bool>();
	private static var _keyNum:Int = 0;
	private static var _press:Array<Int> = new Array<Int>();
	private static var _pressNum:Int = 0;
	private static var _release:Array<Int> = new Array<Int>();
	private static var _releaseNum:Int = 0;
	private static var _control:Map<String,Array<Int>> = new Map<String,Array<Int>>();
	private static var _mouseWheelDelta:Int = 0;
}