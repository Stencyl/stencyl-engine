package com.stencyl;

import com.stencyl.utils.Utils;

import openfl.events.Event;
#if desktop
import openfl.events.JoystickEvent;
#end
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import openfl.geom.Point;

//#if !js
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
//#end

#if (cpp || neko)
import openfl.ui.Accelerometer;
#end

import openfl.ui.Keyboard;
import openfl.Lib;


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
	public static var rightMouseDown:Bool;
	public static var rightMouseUp:Bool;
	public static var rightMousePressed:Bool;
	public static var rightMouseReleased:Bool;
	public static var middleMouseDown:Bool;
	public static var middleMouseUp:Bool;
	public static var middleMousePressed:Bool;
	public static var middleMouseReleased:Bool;
	public static var mouseWheelDelta:Int = 0;
	
	public static var accelX:Float;
	public static var accelY:Float;
	public static var accelZ:Float;
	
	public static var joySensitivity:Float = .12;

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

	public static function enableJoystick()
	{
		if(!_joystickEnabled && Engine.stage != null)
		{
			_joystickEnabled = true;
			#if desktop
			Engine.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove, false, 2);
			Engine.stage.addEventListener(JoystickEvent.BALL_MOVE, onJoyBallMove, false, 2);
			Engine.stage.addEventListener(JoystickEvent.HAT_MOVE, onJoyHatMove, false, 2);
			Engine.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown, false, 2);
			Engine.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp, false, 2);

			//for(i in 0...16)
			//	_joyControllerReady[i] = false;
			#end
		}
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
			#if js
			Engine.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
			Engine.stage.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
			#end
			#if desktop
			Engine.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown, false, 2);
			Engine.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp, false, 2);
			Engine.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown, false, 2);
			Engine.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp, false, 2);
			#end

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
	        	Multitouch.inputMode = openfl.ui.MultitouchInputMode.TOUCH_POINT;
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
		
		#if (openfl_legacy && (cpp || neko))
		if(openfl.sensors.Accelerometer.isSupported)
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
		
		if(rightMousePressed) 
		{
			rightMousePressed = false;
		}
		
		if(rightMouseReleased) 
		{
			rightMouseReleased = false;
		}
		
		if(middleMousePressed) 
		{
			middleMousePressed = false;
		}
		
		if(middleMouseReleased) 
		{
			middleMouseReleased = false;
		}
		
		mouseWheelDelta = 0;
	}
	
	public static function simulateKeyPress(key:String)
	{
		var v:Int = _control.get(key)[0];
		
		Input.onKeyDown(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, v, v));
		
		if(Engine.engine.keyPollOccurred)
		{
			//Due to order of execution, events will never get thrown since the
			//pressed/released flag is reset before the event checker sees it. So
			//throw the event immediately.
			var listeners = Engine.engine.whenKeyPressedListeners.get(key);
			
			if(listeners != null)
			{
				Engine.invokeListeners3(listeners, true, false);
			}
		}
	}
	
	public static function simulateKeyRelease(key:String)
	{
		var v:Int = _control.get(key)[0];
		
		Input.onKeyUp(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, v, v));
		
		if(Engine.engine.keyPollOccurred)
		{
			//Due to order of execution, events will never get thrown since the
			//pressed/released flag is reset before the event checker sees it. So
			//throw the event immediately.
			var listeners = Engine.engine.whenKeyPressedListeners.get(key);
			
			if(listeners != null)
			{
				Engine.invokeListeners3(listeners, false, true);
			}
		}
	}

	public static function onKeyDown(e:KeyboardEvent = null)
	{
		var code:Int = lastKey = e.keyCode;
		
		if (code > 7000)
		{
			return;
		}

		// Update keyString
		
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

		// Update key state

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
		
		if (code > 7000)
		{
			return;
		}
		
		// Update key state

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

	private static function onRightMouseDown(e:MouseEvent)
	{
		if(!rightMouseDown)
		{
			rightMouseDown = true;
			rightMouseUp = false;
			rightMousePressed = true;
		}
	}
	
	private static function onRightMouseUp(e:MouseEvent)
	{
		rightMouseDown = false;
		rightMouseUp = true;
		rightMouseReleased = true;
	}
	
	private static function onMiddleMouseDown(e:MouseEvent)
	{
		if(!middleMouseDown)
		{
			middleMouseDown = true;
			middleMouseUp = false;
			middleMousePressed = true;
		}
	}
	
	private static function onMiddleMouseUp(e:MouseEvent)
	{
		middleMouseDown = false;
		middleMouseUp = true;
		middleMouseReleased = true;
	}
	
	private static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		mouseWheelDelta = e.delta;
	}

	#if desktop
	private static function initJoyController(e:JoystickEvent)
	{
		_joyControllerReady[e.device] = true;

		var a:Array<Int> = [];
		for(f in e.axis)
			a.push(0);
		_joyAxisState.set(e.device, a);
		_joyHatState.set(e.device, [0, 0]);
		_joyButtonState.set(e.device, []);
	}

	private static function onJoyAxisMove(e:JoystickEvent)
	{
		if(!_joyControllerReady[e.device])
			initJoyController(e);

		var oldState:Array<Int> = _joyAxisState.get(e.device);
		
		var cur:Int;
		var old:Int;

		for(i in 0...e.axis.length)
		{
			if(e.axis[i] < -joySensitivity)
				cur = -1;
			else if(e.axis[i] > joySensitivity)
				cur = 1;
			else
				cur = 0;

			old = oldState[i];

			if(cur != old)
			{
				if(old == -1)
					joyRelease(e.device + ", -axis " + i);
				else if(old == 1)
					joyRelease(e.device + ", +axis " + i);
				if(cur == -1)
					joyPress(e.device + ", -axis " + i);
				else if(cur == 1)
					joyPress(e.device + ", +axis " + i);
			}

			oldState[i] = cur;
		}

		_joyAxisPressure.set(e.device, e.axis);
	}

	private static function onJoyBallMove(e:JoystickEvent)
	{
		//not sure what to do with this
	}

	private static function onJoyHatMove(e:JoystickEvent)
	{
		if(!_joyControllerReady[e.device])
			initJoyController(e);
		
		var oldX:Int = _joyHatState.get(e.device)[0];
		var oldY:Int = _joyHatState.get(e.device)[1];

		if(e.x != oldX)
		{
			if(oldX == -1)
				joyRelease(e.device + ", left hat");
			else if(oldX == 1)
				joyRelease(e.device + ", right hat");
			if(e.x == -1)
				joyPress(e.device + ", left hat");
			else if(e.x == 1)
				joyPress(e.device + ", right hat");
		}
		if(e.y != oldY)
		{
			if(oldY == -1)
				joyRelease(e.device + ", up hat");
			else if(oldY == 1)
				joyRelease(e.device + ", down hat");
			if(e.y == -1)
				joyPress(e.device + ", up hat");
			else if(e.y == 1)
				joyPress(e.device + ", down hat");
		}

		_joyHatState.set(e.device, [Std.int(e.x), Std.int(e.y)]);
	}

	private static function onJoyButtonDown(e:JoystickEvent)
	{
		if(!_joyControllerReady[e.device])
			initJoyController(e);

		_joyButtonState.get(e.device)[e.id] = true;
		joyPress(e.device + ", " + e.id);
	}

	private static function onJoyButtonUp(e:JoystickEvent)
	{
		if(!_joyControllerReady[e.device])
			initJoyController(e);

		_joyButtonState.get(e.device)[e.id] = false;
		joyRelease(e.device + ", " + e.id);
	}

	private static function joyPress(id:String)
	{
		if(_joyControlMap.exists(id))
			simulateKeyPress(_joyControlMap.get(id));

		Engine.invokeListeners2(Engine.engine.whenAnyGamepadPressedListeners, id);
	}

	private static function joyRelease(id:String)
	{
		if(_joyControlMap.exists(id))
			simulateKeyRelease(_joyControlMap.get(id));

		Engine.invokeListeners2(Engine.engine.whenAnyGamepadReleasedListeners, id);
	}
	#end

	public static function setJoySensitivity(val:Float)
	{
		#if desktop
		joySensitivity = val;
		#end
	}

	public static function mapJoystickButton(id:String, control:String)
	{
		#if desktop
		var button:JoystickButton = JoystickButton.fromID(id);

		if(_joyControlMap.exists(id))
		{
			var buttons:Array<JoystickButton> = _controlButtonMap.get(_joyControlMap.get(id));

			var i:Int = 0;
			while(i < buttons.length)
			{
				if(buttons[i].equals(button))
					buttons.splice(i--, 1);
				++i;
			}
		}
		
		if(!_controlButtonMap.exists(control))
			_controlButtonMap.set(control, new Array<JoystickButton>());
		_controlButtonMap.get(control).push(button);

		_joyControlMap.set(id, control);
		#end
	}

	public static function getButtonPressure(control:String):Float
	{
		#if desktop

		if(_controlButtonMap.exists(control))
		{
			var buttons = _controlButtonMap.get(control);

			var highestPressure:Float = 0;
			
			for(b in buttons)
			{
				if(!_joyControllerReady[b.a[0]])
					continue;

				switch(b.a[JoystickButton.TYPE])
				{
					case JoystickButton.AXIS:
						if(_joyAxisState.get(b.a[0])[b.a[2]] == b.a[3])
							highestPressure = Math.max(highestPressure, Math.abs(_joyAxisPressure.get(b.a[0])[b.a[2]]));
					case JoystickButton.HAT:
						if(_joyHatState.get(b.a[0])[b.a[2]] == b.a[3])
							return 1;
					case JoystickButton.BUTTON:
						if(_joyButtonState.get(b.a[0])[b.a[2]])
							return 1;
				}
			}

			if(highestPressure == 0 && check(control))
				return 1;

			return highestPressure;
		}
		else
			return check(control) ? 1 : 0;

		#else

		return check(control) ? 1 : 0;

		#end
	}

	private static var joyData:Map<String, Dynamic>;

	public static function saveJoystickConfig(filename:String):Void
	{
		#if desktop
		joyData = new Map<String, Dynamic>();
		joyData.set("_joyControlMap", _joyControlMap);
		joyData.set("joySensitivity", joySensitivity);
		Utils.saveMap(joyData, "_jc-" + filename);
		joyData = null;
		#end
	}

	public static function loadJoystickConfig(filename:String):Void
	{
		#if desktop
		joyData = new Map<String, Dynamic>();
		Utils.loadMap(joyData, "_jc-" + filename, function(success:Bool):Void
		{
			_joyControlMap = joyData.get("_joyControlMap");
			_controlButtonMap = new Map<String,Array<JoystickButton>>();
			for(k in _joyControlMap.keys())
			{
				var control:String = _joyControlMap.get(k);
				var button:JoystickButton = JoystickButton.fromID(k);

				if(!_controlButtonMap.exists(control))
					_controlButtonMap.set(control, new Array<JoystickButton>());
				_controlButtonMap.get(control).push(button);
			}
			joySensitivity = joyData.get("joySensitivity");
			joyData = null;
		});
		#end
	}

	public static function clearJoystickConfig():Void
	{
		_joyControlMap = new Map<String,String>();
		_controlButtonMap = new Map<String,Array<JoystickButton>>();
		joySensitivity = .12;
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

	private static var _joystickEnabled:Bool = false;
	private static var _enabled:Bool = false;
	private static var _key:Array<Bool> = new Array<Bool>();
	private static var _keyNum:Int = 0;
	private static var _press:Array<Int> = new Array<Int>();
	private static var _pressNum:Int = 0;
	private static var _release:Array<Int> = new Array<Int>();
	private static var _releaseNum:Int = 0;
	
	private static var _joyControllerReady:Map<Int, Bool> = new Map<Int,Bool>();
	private static var _joyHatState:Map<Int,Array<Int>> = new Map<Int,Array<Int>>();
	private static var _joyAxisState:Map<Int,Array<Int>> = new Map<Int,Array<Int>>();
	private static var _joyAxisPressure:Map<Int,Array<Float>> = new Map<Int,Array<Float>>();
	private static var _joyButtonState:Map<Int,Array<Bool>> = new Map<Int,Array<Bool>>();

	private static var _joyControlMap:Map<String,String> = new Map<String,String>();
	private static var _controlButtonMap:Map<String,Array<JoystickButton>> = new Map<String,Array<JoystickButton>>();

	private static var _control:Map<String,Array<Int>> = new Map<String,Array<Int>>();
}

class JoystickButton
{
	public static var DEVICE:Int = 0;
	public static var TYPE:Int = 1;

	public static var UP:Int = 0;
	public static var DOWN:Int = 1;
	public static var LEFT:Int = 2;
	public static var RIGHT:Int = 3;

	public static var AXIS:Int = 0;
	public static var HAT:Int = 1;
	public static var BUTTON:Int = 2;
	public static var BALL:Int = 3;

	public static function fromID(id:String):JoystickButton
	{
		var b:JoystickButton = new JoystickButton();
		b.id = id;

		if(id.indexOf("axis") != -1)
		{
			var device:Int = Std.parseInt(id.substr(0, id.indexOf(",")));
			var axis:Int = Std.parseInt(id.substr(id.lastIndexOf(" ") + 1));
			var sign:Int = id.substr(id.indexOf("axis") - 1, 1) == "+" ? 1 : -1;
			b.a = [device, AXIS, axis, sign];
		}
		else if(id.indexOf("hat") != -1)
		{
			var device:Int = Std.parseInt(id.substr(0, id.indexOf(",")));
			var hat:Int = 0;
			var sign:Int = 0;
			switch(id.split(" ")[1])
			{
				case "up": hat = 1; sign = -1;
				case "down": hat = 1; sign = 1;
				case "right": hat = 0; sign = 1;
				case "left": hat = 0; sign = -1;
			}
			b.a = [device, HAT, hat, sign];
		}
		else
		{
			var device:Int = Std.parseInt(id.substr(0, id.indexOf(",")));
			var button:Int = Std.parseInt(id.substr(id.lastIndexOf(" ")));

			b.a = [device, BUTTON, button];
		}

		return b;
	}

	public function new()
	{
		id = "";
		a = [];
	}

	public function equals(b:JoystickButton):Bool
	{
		return id == b.id;
	}

	public var id:String;
	public var a:Array<Int>;
}
