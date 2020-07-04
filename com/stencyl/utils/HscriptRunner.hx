package com.stencyl.utils;

#if (stencyltools && !(scriptable || cppia))

import com.stencyl.behavior.Script;

import hscript.*;

class HscriptRunner
{
	var parser:Parser;
	var interp:Interp;
	
	public function new()
	{
		parser = new Parser();
		interp = new Interp();
		
		interp.variables.set("trace", Reflect.makeVarArgs(function(el) {
			var inf = interp.posInfos();
			inf.className = "Script";
			inf.methodName = "run";
			var v = el.shift();
			if( el.length > 0 ) inf.customParams = el;
			haxe.Log.trace(v, inf);
		}));
		parser.allowTypes = true;
	}
	
	public function registerVar(name:String, obj:Dynamic):Void
	{
		interp.variables.set(name, obj);
	}
	
	public function execute(script:String)
	{
		var program = parser.parseString(script);
		interp.execute(program);
	}
	
	//XXX: Naive list of known types that should work in most cases
	public static function loadDefaults(interp:Interp)
	{
		for(type in [
			"com.stencyl.graphics.G",
			"com.stencyl.graphics.BitmapWrapper",
			"com.stencyl.behavior.Script",
			"com.stencyl.behavior.ActorScript",
			"com.stencyl.behavior.SceneScript",
			"com.stencyl.behavior.TimedTask",
			"com.stencyl.models.Actor",
			"com.stencyl.models.GameModel",
			"com.stencyl.models.actor.Animation",
			"com.stencyl.models.actor.ActorType",
			"com.stencyl.models.actor.Collision",
			"com.stencyl.models.actor.Group",
			"com.stencyl.models.Scene",
			"com.stencyl.models.Sound",
			"com.stencyl.models.Region",
			"com.stencyl.models.Font",
			"com.stencyl.models.Joystick",
			"com.stencyl.Engine",
			"com.stencyl.Input",
			"com.stencyl.Key",
			"com.stencyl.utils.Utils",
			"openfl.ui.Mouse",
			"openfl.display.Graphics",
			"openfl.display.BlendMode",
			"openfl.display.BitmapData",
			"openfl.display.Bitmap",
			"openfl.events.Event",
			"openfl.events.KeyboardEvent",
			"openfl.events.TouchEvent",
			"openfl.net.URLLoader",
			"box2D.common.math.B2Vec2",
			"box2D.dynamics.B2Body",
			"box2D.dynamics.B2Fixture",
			"box2D.dynamics.joints.B2Joint",
			"motion.Actuate",
			"motion.easing.Back",
			"motion.easing.Cubic",
			"motion.easing.Elastic",
			"motion.easing.Expo",
			"motion.easing.Linear",
			"motion.easing.Quad",
			"motion.easing.Quart",
			"motion.easing.Quint",
			"motion.easing.Sine",
			"com.stencyl.graphics.shaders.BasicShader",
			"com.stencyl.graphics.shaders.GrayscaleShader",
			"com.stencyl.graphics.shaders.SepiaShader",
			"com.stencyl.graphics.shaders.InvertShader",
			"com.stencyl.graphics.shaders.GrainShader",
			"com.stencyl.graphics.shaders.ExternalShader",
			"com.stencyl.graphics.shaders.InlineShader",
			"com.stencyl.graphics.shaders.BlurShader",
			"com.stencyl.graphics.shaders.SharpenShader",
			"com.stencyl.graphics.shaders.ScanlineShader",
			"com.stencyl.graphics.shaders.CSBShader",
			"com.stencyl.graphics.shaders.HueShader",
			"com.stencyl.graphics.shaders.TintShader",
			"com.stencyl.graphics.shaders.BloomShader"
		])
		{
			var resolvedType = Type.resolveClass(type);
			if(resolvedType != null)
			{
				interp.variables.set(type.split(".").pop(), resolvedType);
			}
		}
		
		interp.variables.set("sameAs", sameAs);
		interp.variables.set("sameAsAny", sameAsAny);
		interp.variables.set("asBoolean", asBoolean);
		interp.variables.set("strCompare", strCompare);
		interp.variables.set("strCompareBefore", strCompareBefore);
		interp.variables.set("strCompareAfter", strCompareAfter);
		interp.variables.set("asNumber", asNumber);
		interp.variables.set("hasValue", hasValue);
	}
	
	//inline Script.hx functions copied here to be un-inlined for hscript access.
	
	public static function sameAs(o:Dynamic, o2:Dynamic):Bool
	{
		return o == o2;
	}
	
	public static function sameAsAny(o:Dynamic, one:Dynamic, two:Dynamic):Bool
	{
		return (o == one) || (o == two);
	}
	
	public static function asBoolean(o:Dynamic):Bool
	{
		if (o == true)
		{
			return true;
		}
		else if (o == "true")
		{
			return true;
		}
		else
		{
			return false;
		}
		//return (o == true || o == "true"); // This stopped working in 3.5: http://community.stencyl.com/index.php?issue=845.0
	}
	
	public static function strCompare(one:String, two:String, whichWay:Int):Bool
	{
		if(whichWay < 0)
		{
			return strCompareBefore(one, two);
		}
		
		else
		{
			return strCompareAfter(one, two);
		}
	}
	
	public static function strCompareBefore(a:String, b:String):Bool
	{
		return(a < b);
	} 
	
	public static function strCompareAfter(a:String, b:String):Bool
	{
		return(a > b);
	} 
	
	public static function asNumber(o:Dynamic):Float
	{
		if(o == null)
		{
			return 0;
		}

		else if(Std.is(o, Float))
		{
			return cast(o, Float);
		}
		
		else if(Std.is(o, Int))
		{
			return cast(o, Int);
		}
		
		else if(Std.is(o, Bool))
		{
			return cast(o, Bool) ? 1 : 0;
		}
		
		else if(Std.is(o, String))
		{
			return Std.parseFloat(o);
		}
		
		else
		{
			return Std.parseFloat(Std.string(o));
		}
	}
	
	public static function hasValue(o:Dynamic):Bool
	{
		if(Script.isPrimitive(o))
		{
			return true;
		}
		
		else if(Std.is(o, String))
		{
			return cast(o, String) != "";
		}
		
		else
		{
			return o != null;
		}
	}
}

#end