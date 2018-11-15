package com.stencyl;

import com.stencyl.Config;
import com.stencyl.utils.Utils;

import openfl.events.Event;
#if desktop
import lime.ui.Joystick;
import lime.ui.JoystickHatPosition;
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
import openfl.sensors.Accelerometer;
#end

import openfl.ui.Keyboard;
import openfl.Lib;


class Input
{
	//global state
	private static var _enabled:Bool = false;
	private static var _joystickEnabled:Bool = false;
	
	//mouse state
	public static var mouseX:Float = 0;
	public static var mouseY:Float = 0;
	public static var mouseWheel:Bool;
	public static var mouseWheelDelta:Int = 0;
	
	public static var mouseDown:Bool;
	public static var mousePressed:Bool;
	public static var mouseReleased:Bool;
	public static var rightMouseDown:Bool;
	public static var rightMousePressed:Bool;
	public static var rightMouseReleased:Bool;
	public static var middleMouseDown:Bool;
	public static var middleMousePressed:Bool;
	public static var middleMouseReleased:Bool;
	
	//accelerometer state
	public static var accelX:Float;
	public static var accelY:Float;
	public static var accelZ:Float;
	
	//gestures state
	#if !js
	public static var multiTouchEnabled:Bool;
	public static var multiTouchPoints:Map<String,TouchEvent>;
	#end
	
	public static var numTouches:Int;

	private static var roxAgent:RoxGestureAgent;
	private static var swipeDirection:Int;
	public static var swipedUp:Bool;
	public static var swipedDown:Bool;
	public static var swipedLeft:Bool;
	public static var swipedRight:Bool;
	
	//joystick state
	public static var joySensitivity:Float = .12;

	private static var _joyHatState:Map<Int,Array<Int>> = new Map<Int,Array<Int>>();
	private static var _joyAxisState:Map<Int,Array<Int>> = new Map<Int,Array<Int>>();
	private static var _joyAxisPressure:Map<Int,Array<Float>> = new Map<Int,Array<Float>>();
	private static var _joyButtonState:Map<Int,Array<Bool>> = new Map<Int,Array<Bool>>();
	
	//keyboard state
	private static var _key:Array<Bool> = new Array<Bool>();
	
	//key string
	private static inline var kKeyStringMax = 100;
	public static var keyString:String = "";
	
	public static var lastEvent:KeyboardEvent;
	public static var lastKey:Int;
	
	//control state
	private static var _controlsToReset:Array<Control> = new Array<Control>();
	private static var _controlMap:Map<String,Control> = new Map<String,Control>();
	
	private static var _keyControlMap:Map<Int,Control> = new Map<Int,Control>();
	#if desktop
	private static var _joyControlMap:Map<String,Control> = new Map<String,Control>();
	#end
	
	public static function resetStatics():Void
	{
		//global effects

		Engine.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Engine.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Engine.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Engine.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Engine.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#if js
		Engine.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
		Engine.stage.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
		#end
		#if desktop
		Engine.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		Engine.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		Engine.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown);
		Engine.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp);
		#end

		#if(mobile && android)
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, ignoreBackKey);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, ignoreBackKey);
		#end
		
		#if !js
		if(Multitouch.supportsTouchEvents)
		{
			Engine.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			Engine.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			Engine.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		#end

		roxAgent.detach();
		Engine.engine.root.removeEventListener(RoxGestureEvent.GESTURE_SWIPE, onSwipe);

		//statics

		keyString = "";
		lastEvent = null;
		lastKey = 0;
		mouseX = 0; mouseY = 0;
		mouseDown = mousePressed = mouseReleased = mouseWheel = false;
		rightMouseDown = rightMousePressed = rightMouseReleased = false;
		middleMouseDown = middleMousePressed = middleMouseReleased = false;
		mouseWheelDelta = 0;
		accelX = accelY = accelZ = 0;
		joySensitivity = .12;
		
		#if !js
		multiTouchEnabled = false;
		multiTouchPoints = null;
		#end

		numTouches = 0;
		swipeDirection = 0;
		swipedUp = swipedDown = swipedRight = swipedLeft = false;
		roxAgent = null;
		
		_joystickEnabled = false;
		_enabled = false;
		_key = new Array<Bool>();
		
		_joyHatState = new Map<Int,Array<Int>>();
		_joyAxisState = new Map<Int,Array<Int>>();
		_joyAxisPressure = new Map<Int,Array<Float>>();
		_joyButtonState = new Map<Int,Array<Bool>>();

		#if desktop
		_joyControlMap = new Map<String,Control>();
		#end
		_keyControlMap = new Map<Int,Control>();

		_controlMap = new Map<String,Control>();
		_controlsToReset = new Array<Control>();
	}

	/**
	 * Returns the control->key map.
	 */
	public static function getControlMap():Map<String,Control>
	{
		return _controlMap;
	}
	
	/**
	 * Defines a new input.
	 * @param	name		String to map the input to.
	 * @param	...keys		The keys to use for the Input.
	 */
	public static function define(controlName:String):Control
	{
		var control = new Control(controlName);
		_controlMap.set(controlName, control);
		return control;
	}

	/**
	 * If the input is held down.
	 * @param	input		An input name to check for.
	 * @return	True or false.
	 */
	public static function check(controlName:String):Bool
	{
		var control = _controlMap.get(controlName);
		
		return control != null && control.down;
	}

	/**
	 * If the input was pressed this frame.
	 * @param	input		An input name to check for.
	 * @return	True or false.
	 */
	public static function pressed(controlName:String):Bool
	{
		var control = _controlMap.get(controlName);
		
		return control != null && control.pressed;
	}

	/**
	 * If the input was released this frame.
	 * @param	input		An input name to check for.
	 * @return	True or false.
	 */
	public static function released(controlName:String):Bool
	{
		var control = _controlMap.get(controlName);
		
		return control != null && control.released;
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

			var addJoystick = function (joystick:Joystick) {

				trace ("Connected Joystick: " + joystick.name);

				_joyAxisState.set(joystick.id, [for(i in 0...joystick.numAxes) 0]);
				_joyAxisPressure.set(joystick.id, [for(i in 0...joystick.numAxes) 0.0]);
				_joyHatState.set(joystick.id, [0, 0]);
				_joyButtonState.set(joystick.id, []);

				joystick.onAxisMove.add (function (axis:Int, value:Float) {
					onJoyAxisMove(joystick, axis, value);
				});

				joystick.onButtonDown.add (function (button:Int) {
					onJoyButtonDown(joystick, button);
				});

				joystick.onButtonUp.add (function (button:Int) {
					onJoyButtonUp(joystick, button);
				});

				joystick.onHatMove.add (function (hat:Int, position:JoystickHatPosition) {
					onJoyHatMove(joystick, hat, position);
				});

				joystick.onTrackballMove.add (function (trackball:Int, x:Float, y:Float) {
					onJoyBallMove(joystick, trackball, x, y);
				});

				joystick.onDisconnect.add (function () {
					trace ("Disconnected Joystick: " + joystick.name);
				});

			}

			Joystick.onConnect.add (addJoystick);

			for(joystick in Joystick.devices)
			{
				addJoystick(joystick);
			}

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
			if(Config.disableBackButton)
			{
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, ignoreBackKey);
				Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, ignoreBackKey);
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
	        
			roxAgent = new RoxGestureAgent(Engine.engine.root, RoxGestureAgent.GESTURE);
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

	private static function ignoreBackKey(event:KeyboardEvent = null)
	{
		lastEvent = event;

		if(lastEvent.keyCode == lime.ui.KeyCode.APP_CONTROL_BACK)
		{
			lastEvent.preventDefault();

			var control = _keyControlMap.get(lime.ui.KeyCode.ESCAPE);
			
			if (lastEvent.type == KeyboardEvent.KEY_DOWN)
			{
				controlPressed(control);
			}
			else
			{
				controlReleased(control);
			}
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

	@:access(openfl.sensors.Accelerometer)
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
		
		#if (cpp || neko)
		if(Accelerometer.isSupported)
		{
			accelX = Accelerometer.currentX;
			accelY = Accelerometer.currentY;
			accelZ = Accelerometer.currentZ;
		}
		#end
		
		//Mouse is always in absolute coordinates, so adjust when screen size != game size
		mouseX = (Engine.stage.mouseX - Engine.screenOffsetX) / Engine.screenScaleX;
		mouseY = (Engine.stage.mouseY - Engine.screenOffsetY) / Engine.screenScaleY;
	
		var i = _controlsToReset.length;
		while(--i >= 0)
		{
			var control = _controlsToReset.pop();
			control.pressed = false;
			control.released = false;
		}
		
		if(mousePressed) mousePressed = false;
		if(mouseReleased) mouseReleased = false;
		if(rightMousePressed) rightMousePressed = false;
		if(rightMouseReleased) rightMouseReleased = false;
		if(middleMousePressed) middleMousePressed = false;
		if(middleMouseReleased) middleMouseReleased = false;
		
		mouseWheelDelta = 0;
	}
	
	public static function simulateKeyPress(controlName:String)
	{
		controlPressed(_controlMap.get(controlName));
	}
	
	private static function controlPressed(control:Control)
	{
		if(control == null) return;
		
		if(!control.down)
		{
			control.down = true;
			control.pressed = true;
			control.pressure = 1.0;
			_controlsToReset.push(control);
		}
		
		if(Engine.engine.keyPollOccurred)
		{
			//Due to order of execution, events will never get thrown since the
			//pressed/released flag is reset before the event checker sees it. So
			//throw the event immediately.
			var listeners = Engine.engine.whenKeyPressedListeners.get(control.name);
			
			if(listeners != null)
			{
				Engine.invokeListeners3(listeners, true, false);
			}
		}
	}
	
	public static function simulateKeyRelease(controlName:String)
	{
		controlReleased(_controlMap.get(controlName));
	}
	
	private static function controlReleased(control:Control)
	{
		if(control == null) return;
		
		if(control.down)
		{
			control.down = false;
			control.released = true;
			control.pressure = 0.0;
			_controlsToReset.push(control);
		}
		
		if(Engine.engine.keyPollOccurred)
		{
			//Due to order of execution, events will never get thrown since the
			//pressed/released flag is reset before the event checker sees it. So
			//throw the event immediately.
			var listeners = Engine.engine.whenKeyPressedListeners.get(control.name);
			
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
			controlPressed(_keyControlMap.get(code));
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
			controlReleased(_keyControlMap.get(code));
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
		mouseReleased = true;
	}

	private static function onRightMouseDown(e:MouseEvent)
	{
		if(!rightMouseDown)
		{
			rightMouseDown = true;
			rightMousePressed = true;
		}
	}
	
	private static function onRightMouseUp(e:MouseEvent)
	{
		rightMouseDown = false;
		rightMouseReleased = true;
	}
	
	private static function onMiddleMouseDown(e:MouseEvent)
	{
		if(!middleMouseDown)
		{
			middleMouseDown = true;
			middleMousePressed = true;
		}
	}
	
	private static function onMiddleMouseUp(e:MouseEvent)
	{
		middleMouseDown = false;
		middleMouseReleased = true;
	}
	
	private static function onMouseWheel(e:MouseEvent)
	{
		mouseWheel = true;
		mouseWheelDelta = e.delta;
	}

	#if desktop
	
	private static function onJoyAxisMove(joystick:Joystick, axis:Int, value:Float)
	{
		var oldState:Array<Int> = _joyAxisState.get(joystick.id);
		
		var cur:Int;
		var old:Int;

		if(value < -joySensitivity)
			cur = -1;
		else if(value > joySensitivity)
			cur = 1;
		else
			cur = 0;

		old = oldState[axis];

		if(cur != old)
		{
			if(old == -1)
				joyRelease(joystick.id + ", -axis " + axis);
			else if(old == 1)
				joyRelease(joystick.id + ", +axis " + axis);
			if(cur == -1)
				joyPress(joystick.id + ", -axis " + axis, Math.abs(value));
			else if(cur == 1)
				joyPress(joystick.id + ", +axis " + axis, Math.abs(value));
		}

		oldState[axis] = cur;

		_joyAxisPressure.get(joystick.id)[axis] = value;
	}
	
	private static function onJoyBallMove(joystick:Joystick, trackball:Int, x:Float, y:Float)
	{
		//not sure what to do with this
	}

	private static function onJoyHatMove(joystick:Joystick, hat:Int, position:JoystickHatPosition)
	{
		var oldX:Int = _joyHatState.get(joystick.id)[0];
		var oldY:Int = _joyHatState.get(joystick.id)[1];

		var newX:Int = position.left ? -1 : position.right ? 1 : 0;
		var newY:Int = position.up ? -1 : position.down ? 1 : 0;

		if(newX != oldX)
		{
			if(oldX == -1)
				joyRelease(joystick.id + ", left hat");
			else if(oldX == 1)
				joyRelease(joystick.id + ", right hat");
			if(newX == -1)
				joyPress(joystick.id + ", left hat");
			else if(newX == 1)
				joyPress(joystick.id + ", right hat");
		}
		if(newY != oldY)
		{
			if(oldY == -1)
				joyRelease(joystick.id + ", up hat");
			else if(oldY == 1)
				joyRelease(joystick.id + ", down hat");
			if(newY == -1)
				joyPress(joystick.id + ", up hat");
			else if(newY == 1)
				joyPress(joystick.id + ", down hat");
		}

		_joyHatState.set(joystick.id, [newX, newY]);
	}

	private static function onJoyButtonDown(joystick:Joystick, button:Int)
	{
		_joyButtonState.get(joystick.id)[button] = true;
		joyPress(joystick.id + ", " + button);
	}

	private static function onJoyButtonUp(joystick:Joystick, button:Int)
	{
		_joyButtonState.get(joystick.id)[button] = false;
		joyRelease(joystick.id + ", " + button);
	}

	private static function joyPress(id:String, ?pressure:Float = 0.0)
	{
		var control = _joyControlMap.get(id);
		controlPressed(control);
		if(pressure != 0.0)
		{
			control.pressure = pressure;
		}
		
		Engine.invokeListeners2(Engine.engine.whenAnyGamepadPressedListeners, id);
	}

	private static function joyRelease(id:String)
	{
		controlReleased(_joyControlMap.get(id));

		Engine.invokeListeners2(Engine.engine.whenAnyGamepadReleasedListeners, id);
	}
	#end

	public static function setJoySensitivity(val:Float)
	{
		#if desktop
		joySensitivity = val;
		#end
	}

	public static function mapJoystickButton(id:String, controlName:String)
	{
		#if desktop
		var button:JoystickButton = JoystickButton.fromID(id);
		var control = _joyControlMap.get(id);
		if(control != null)
			control.buttons.remove(button);
		
		var newControl = _controlMap.get(controlName);
		newControl.buttons.push(button);
		
		_joyControlMap.set(id, newControl);
		#end
	}
	
	public static function unMapJoystickButton(id:String)
	{
		#if desktop
		var button:JoystickButton = JoystickButton.fromID(id);
		var control = _joyControlMap.get(id);
		if(control != null)
			control.buttons.remove(button);
		
		_joyControlMap.remove(id);
		#end
	}
	
	public static function unMapControl(controlName:String)
	{
		#if desktop
		var control = _controlMap.get(controlName);

		for(k in _joyControlMap.keys())
		{
			if (_joyControlMap.get(k) == control)
			{
				_joyControlMap.remove(k);
				control.buttons.remove(JoystickButton.fromID(k));
			}
		}
		#end
	}

	public static function getButtonPressure(controlName:String):Float
	{
		var control = _controlMap.get(controlName);
		
		if(control != null)
		{
			return control.pressure;
		}
		
		return 0.0;
	}

	public static function saveJoystickConfig(filename:String):Void
	{
		#if desktop
		var joyData = new Map<String, Dynamic>();
		joyData.set("_joyControlMap", [for (key in _joyControlMap.keys()) key => _joyControlMap.get(key).name]);
		joyData.set("joySensitivity", joySensitivity);
		Utils.saveMap(joyData, "_jc-" + filename);
		#end
	}

	public static function loadJoystickConfig(filename:String):Void
	{
		#if desktop
		clearJoystickConfig();
		var joyData = new Map<String, Dynamic>();
		Utils.loadMap(joyData, "_jc-" + filename, function(success:Bool):Void
		{
			if (Utils.mapCount(joyData) > 0)
			{
				var joyStringMap:Map<String,String> = joyData.get("_joyControlMap");
				for(k in joyStringMap.keys())
				{
					var controlName = joyStringMap.get(k);
					var control = _controlMap.get(controlName);
					_joyControlMap.set(k, control);
					
					var button = JoystickButton.fromID(k);
					
					control.buttons.push(button);
				}
				joySensitivity = joyData.get("joySensitivity");
			}
		});
		#end
	}

	public static function clearJoystickConfig():Void
	{
		for(control in _controlMap)
		{
			control.buttons = [];
		}
		_joyControlMap = new Map<String,Control>();
		joySensitivity = .12;
	}

	public static function loadInputConfig():Void
	{
		for(stencylControl in Config.keys.keys())
		{
			var value = Config.keys.get(stencylControl);
			var keyboardConstList = [for (keyname in value) Key.keyFromName(keyname)];
			
			var control = define(stencylControl);
			control.keys = keyboardConstList;
			for(key in control.keys)
			{
				_keyControlMap.set(key, control);
			}
		}
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
}

class Control
{
	public var name:String;
	public var keys:Array<Int>;
	#if desktop
	public var buttons:Array<JoystickButton>;
	#end
	public var pressed:Bool;
	public var released:Bool;
	public var down:Bool;
	public var pressure:Float;
	
	public function new(name:String)
	{
		this.name = name;
		keys = [];
		#if desktop
		buttons = [];
		#end
	}
}

class JoystickButton
{
	public static inline var DEVICE:Int = 0;
	public static inline var TYPE:Int = 1;

	public static inline var UP:Int = 0;
	public static inline var DOWN:Int = 1;
	public static inline var LEFT:Int = 2;
	public static inline var RIGHT:Int = 3;

	public static inline var AXIS:Int = 0;
	public static inline var HAT:Int = 1;
	public static inline var BUTTON:Int = 2;
	public static inline var BALL:Int = 3;
	
	private static var cacheFromID:Map<String, JoystickButton> = new Map<String, JoystickButton>();

	public static function fromID(id:String):JoystickButton
	{
		if(cacheFromID.exists(id))
			return cacheFromID.get(id);
		
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
		
		cacheFromID.set(id, b);
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
