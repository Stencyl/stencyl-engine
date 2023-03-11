package com.stencyl.native;

import com.stencyl.Engine;
import com.stencyl.Extension;
import com.stencyl.event.Event;
import com.stencyl.models.Scene;

#if ios
import lime.system.CFFI;
#elseif android
import lime.system.JNI;
#end

import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;

using com.stencyl.event.EventDispatcher;

typedef KeyEventData = {
	var eventType:KeyEventType;
	var currentText:String;
}

enum KeyEventType {
	KEY_PRESSED;
	ENTER_PRESSED;
	KEYBOARD_SHOWN;
	KEYBOARD_HIDDEN;
}

#if ios
@:buildXml('<include name="${haxelib:com.stencyl.native}/project/Build.xml"/>')
//This is just here to prevent the otherwise indirectly referenced native code from bring stripped at link time.
@:cppFileCode('extern "C" int native_register_prims();void com_stencyl_native_link(){native_register_prims();}')
#end
class Native extends Extension
{
	//stencyl events
	public static var keyEvents:Event<(eventType:KeyEventType,currentText:String)->Void>;
	public static var nativeEventQueue:Array<KeyEventData> = [];

	public function new()
	{
		super();
	}

	//Stencyl event plumbing

	public override function loadScene(scene:Scene)
	{
		keyEvents = new Event<(KeyEventType,String)->Void>();
	}
	
	public override function cleanupScene()
	{
		keyEvents = null;
	}

	public override function preSceneUpdate()
	{
		for(event in nativeEventQueue)
		{
			keyEvents.dispatch(event.eventType, event.currentText);
		}
		nativeEventQueue.splice(0, nativeEventQueue.length);
	}
	
	public static function osName():String
	{
		#if ios
		return native_device_os();
		#elseif android
		return "";
		#else
		return "";
		#end
	}
	
	public static function osVersion():String
	{
		#if ios
		return native_device_vervion();
		#elseif android
		return "";
		#else
		return "";
		#end
	}
	
	public static function deviceName():String
	{
		#if ios
		return native_device_name();
		#elseif android
		return "";
		#else
		return "";
		#end
	}
	
	public static function model():String
	{
		#if ios
		return native_device_model();
		#elseif android
		return "";
		#else
		return "";
		#end
	}
	
	public static function networkAvailable():Bool
	{
		#if ios
		return native_device_network_available();
		#elseif android
		return false;
		#else
		return false;
		#end
	}
	
	public static function vibrate(time:Float):Void
	{
		#if ios
		native_device_vibrate(time);
		#end
		
		#if android
		if(funcVibrate == null)
		{
			funcVibrate = JNI.createStaticMethod("com/androidnative/Native", "vibrate", "(I)V", true);
		}
		
		funcVibrate([time * 1000]);
		#end
	}
	
	//Keyboard
	public static function showKeyboard():Void
	{
		#if ios
		initKeyboard();
		native_device_show_keyboard();
		nativeEventQueue.push({"eventType": KEYBOARD_SHOWN, "currentText": ""});
		#end
		
		#if android
		initKeyboard();
		
		if(funcShowKeyboard == null)
		{
			funcShowKeyboard = JNI.createStaticMethod("com/androidnative/Native", "showKeyboard", "()V", true);
		}
		
		funcShowKeyboard([]);
		nativeEventQueue.push({"eventType": KEYBOARD_SHOWN, "currentText": ""});
		#end
	}
	
	public static function hideKeyboard():Void
	{
		#if ios
		initKeyboard();
		native_device_hide_keyboard();
		nativeEventQueue.push({"eventType": KEYBOARD_HIDDEN, "currentText": ""});
		#end
		
		#if android
        initKeyboard();
 
		if(funcHideKeyboard == null)
		{
			funcHideKeyboard = JNI.createStaticMethod("com/androidnative/Native", "hideKeyboard", "()V", true);
		}
		
		funcHideKeyboard([]);
		nativeEventQueue.push({"eventType": KEYBOARD_HIDDEN, "currentText": ""});
		#end
	}
	
	public static function setKeyboardText(text:String):Void
	{
		#if ios
		native_setKeyboardText(text);
		#end
		
		#if android
		if(funcSetKeyboardText == null)
		{
			funcSetKeyboardText = JNI.createStaticMethod("com/androidnative/Native", "setText", "(Ljava/lang/String;)V", true);
		}
		
		funcSetKeyboardText([text]);
		#end
	}
	
	public static function initKeyboard():Void 
	{
		#if ios
		if(!keyboardInitialized)
		{
			keyboard_set_event_handle(notifyListeners);
			keyboardInitialized = true;
		}
		#end
		
		#if android
		if(!keyboardInitialized)
		{
			if(funcKeyboardInitialized == null)
			{
				funcKeyboardInitialized = JNI.createStaticMethod("com/androidnative/Native", "initialize", "(Lorg/haxe/lime/HaxeObject;)V", true);
			}
			var args = new Array<Dynamic>();
            args.push(new Native());
            funcKeyboardInitialized(args);
			
			keyboardInitialized = true;
		}
		#end
	}
	
	private static function notifyListeners(inEvent:Dynamic)
	{
		#if ios
		
		//Fire a special event
		var data = Reflect.field(inEvent, "data");
		trace("Text: " + data);
		
		if(data == "@SUBMIT@")
		{
			data = Reflect.field(inEvent, "data2");
			nativeEventQueue.push({"eventType": ENTER_PRESSED, "currentText": data});
		}
		
		else
		{
			nativeEventQueue.push({"eventType": KEY_PRESSED, "currentText": data});
		}
		#end	
	}
	
	//Android callbacks
	public function onKeyPressed(typedText:String = "") {
        #if android
		
        currentText = typedText;
		
		trace(currentText);
		
        nativeEventQueue.push({"eventType": KEY_PRESSED, "currentText": currentText});
        #end
    }

    public function onEnterPressed() {
        #if android
        nativeEventQueue.push({"eventType": ENTER_PRESSED, "currentText": currentText});
        #end
    }

    public function onKeyboardShown() {
        #if android
        nativeEventQueue.push({"eventType": KEYBOARD_SHOWN, "currentText": currentText});
        #end
    }

    public function onKeyboardHidden() {
        #if android
        nativeEventQueue.push({"eventType": KEYBOARD_HIDDEN, "currentText": currentText});
        #end
    }
	
	public function onPause()
	{
		keyboardInitialized = false;
	}
	
	//Badge
	public static function setIconBadgeNumber(n:Int):Void
	{
		#if ios
		native_device_badge(n);
		#end
	}

	//Alert
	
	private static var alertTitle:String;
	private static var alertMSG:String;

	public static function showAlert(title:String, message:String):Void
	{
		alertTitle = title;
		alertMSG = message;
		haxe.Timer.delay(delayAlert, 30);
	}
	
	private static function delayAlert():Void
	{
		#if ios
		native_system_ui_show_alert(alertTitle, alertMSG);
		#end
		
		#if android
		if(funcAlert == null)
		{
			funcAlert = JNI.createStaticMethod("com/androidnative/Native", "showAlert", "(Ljava/lang/String;Ljava/lang/String;)V", true);
		}
		
		funcAlert([alertTitle, alertMSG]);
		#end
	}
	
	//Spinner - No Android Equivalent
	
	public static function showLoadingScreen():Void
	{
		#if ios
		native_system_ui_show_system_loading_view();
		#end
	}	
	
	public static function hideLoadingScreen():Void
	{
		#if ios
		native_system_ui_hide_system_loading_view();
		#end
	}
	
	//Preferences
	
	public static function getUserPreference(name:String):String
	{
		#if ios
		return native_get_user_preference(name);
		#end
		
		#if android
		if(funcGetPreference == null)
		{
			funcGetPreference = JNI.createStaticMethod("com/androidnative/Native", "getUserPreference", "(Ljava/lang/String;)Ljava/lang/String;", true);
		}
		
		return funcGetPreference([name]);
		#end
	}
	
	public static function setUserPreference(name:String, value:String):Bool
	{
		#if ios
		native_set_user_preference(name, value);
		#end
		
		#if android
		if(funcSetPreference == null)
		{
			funcSetPreference = JNI.createStaticMethod("com/androidnative/Native", "setUserPreference", "(Ljava/lang/String;)V", true);
		}
		
		funcSetPreference([name, value]);
		#end
		
		return true;
	}
	
	public static function clearUserPreference(name:String):Bool
	{
		#if ios
		native_clear_user_preference(name);
		#end
		
		#if android
		if(funcClearPreference == null)
		{
			funcClearPreference = JNI.createStaticMethod("com/androidnative/Native", "clearUserPreference", "(Ljava/lang/String;)V", true);
		}
		
		funcClearPreference([name]);
		#end
		
		return true;
	}

	/**
	 * Insets from the four sides, in pixels, given the current device orientation.
	 */
	public static function getSafeInsets():Rectangle
	{
		var left = 0;
		var top = 0;
		var right = 0;
		var bottom = 0;

		#if ios
		left = native_get_safe_inset_left();
		top = native_get_safe_inset_top();
		right = native_get_safe_inset_right();
		bottom = native_get_safe_inset_bottom();
		#end

		#if android
		if(funcGetSafeInsetLeft == null)
		{
			funcGetSafeInsetLeft = JNI.createStaticMethod("org/haxe/lime/GameActivity", "getSafeInsetLeft", "()I", true);
			funcGetSafeInsetTop = JNI.createStaticMethod("org/haxe/lime/GameActivity", "getSafeInsetTop", "()I", true);
			funcGetSafeInsetRight = JNI.createStaticMethod("org/haxe/lime/GameActivity", "getSafeInsetRight", "()I", true);
			funcGetSafeInsetBottom = JNI.createStaticMethod("org/haxe/lime/GameActivity", "getSafeInsetBottom", "()I", true);
		}

		left = funcGetSafeInsetLeft();
		top = funcGetSafeInsetTop();
		right = funcGetSafeInsetRight();
		bottom = funcGetSafeInsetBottom();
		#end

		return new Rectangle(left, top, right, bottom);
	}
	
	#if android
	private static var funcAlert:Dynamic;
	private static var funcVibrate:Dynamic;
	private static var funcShowKeyboard:Dynamic;
	private static var funcHideKeyboard:Dynamic;
	private static var funcGetPreference:Dynamic;
	private static var funcSetPreference:Dynamic;
	private static var funcClearPreference:Dynamic;
	private static var funcGetSafeInsetLeft:Dynamic;
	private static var funcGetSafeInsetTop:Dynamic;
	private static var funcGetSafeInsetRight:Dynamic;
	private static var funcGetSafeInsetBottom:Dynamic;
	//edit byRobin
	private static var funcKeyboardInitialized:Dynamic;
	private static var funcSetKeyboardText:Dynamic;
	private static var currentText:String = "";
	#end
	
	private static var keyboardInitialized:Bool = false;
	
	#if ios
	static var keyboard_set_event_handle = CFFI.load("native","keyboard_set_event_handle",1);
	
	static var native_device_os = CFFI.load("native","native_device_os",0);
	static var native_device_vervion = CFFI.load("native","native_device_vervion",0);
	static var native_device_name = CFFI.load("native","native_device_name",0);
	static var native_device_model = CFFI.load("native","native_device_model",0);
	static var native_device_network_available = CFFI.load("native","native_device_network_available",0);
	static var native_device_vibrate = CFFI.load("native","native_device_vibrate",1);
	static var native_device_badge = CFFI.load("native","native_device_badge",1);
	
	static var native_device_show_keyboard = CFFI.load("native","native_device_show_keyboard",0);
	static var native_device_hide_keyboard = CFFI.load("native","native_device_hide_keyboard",0);
	static var native_setKeyboardText = CFFI.load("native","native_setKeyboardText",1);
	
	static var native_system_ui_show_alert = CFFI.load("native","native_system_ui_show_alert",2);
	static var native_system_ui_show_system_loading_view = CFFI.load("native","native_system_ui_show_system_loading_view",0);
	static var native_system_ui_hide_system_loading_view = CFFI.load("native","native_system_ui_hide_system_loading_view",0);
	static var native_system_ui_hide_launch_storyboard = CFFI.load("native","native_system_ui_hide_launch_storyboard",0);

	static var native_get_user_preference = CFFI.load("native","native_get_user_preference",1);
	static var native_set_user_preference = CFFI.load("native","native_set_user_preference",2);
	static var native_clear_user_preference = CFFI.load("native","native_clear_user_preference",1);

	static var native_get_safe_inset_left = CFFI.load("native","native_get_safe_inset_left",0);
	static var native_get_safe_inset_top = CFFI.load("native","native_get_safe_inset_top",0);
	static var native_get_safe_inset_right = CFFI.load("native","native_get_safe_inset_right",0);
	static var native_get_safe_inset_bottom = CFFI.load("native","native_get_safe_inset_bottom",0);
	#end
}