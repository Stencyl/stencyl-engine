package;

import nme.Assets;
import com.stencyl.Engine;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;

//LAST PART: Implement the hook between SW and initialize - set the target and the images, type is static

class JoystickController 
{	
	public static var joystick1:Joystick = null;
	public static var joystick2:Joystick = null;
	
	public static function initialize()
	{	
		if(joystick1 == null || joystick2 == null)
		{
			var target = Engine.engine.root;
			var outer:BitmapData = null;
			var inner:BitmapData = null;
		
			if(Engine.SCALE == 1)
			{
				outer = Assets.getBitmapData("assets/graphics/outer-joystick.png");
				inner = Assets.getBitmapData("assets/graphics/inner-joystick.png");
			}
			
			else if(Engine.SCALE == 1.5)
			{
				outer = Assets.getBitmapData("assets/graphics/outer-joystick@1.5x.png");
				inner = Assets.getBitmapData("assets/graphics/inner-joystick@1.5x.png");
			}
			
			else if(Engine.SCALE == 2)
			{
				outer = Assets.getBitmapData("assets/graphics/outer-joystick@2x.png");
				inner = Assets.getBitmapData("assets/graphics/inner-joystick@2x.png");
			}
			
			else
			{
				outer = Assets.getBitmapData("assets/graphics/outer-joystick@4x.png");
				inner = Assets.getBitmapData("assets/graphics/inner-joystick@4x.png");
			}
			
			joystick1 = createJoystick(target, outer, inner, Joystick.JoystickStatic);
			joystick2 = createJoystick(target, outer, inner, Joystick.JoystickStatic);
		}
	}
	
	public static function setStyle(joystick:Int, style:Int)
	{
		initialize();
		
		if(style > 0)
		{
			style = Joystick.JoystickAbsolute;
		}
		
		else
		{
			style = Joystick.JoystickStatic;
		}
	
		if(joystick == 1)
		{
			joystick1.setType(style);
		}
		
		else if(joystick == 2)
		{
			joystick2.setType(style);
		}
		
		else
		{
			joystick1.setType(style);
			joystick2.setType(style);
		}
	}
	
	public static function setX(joystick:Int, x:Float)
	{
		x = Std.int(x);
	
		initialize();
	
		if(joystick == 1 && joystick1.mType == Joystick.JoystickStatic)
		{
			joystick1.x = x;
		}
		
		else if(joystick == 2 && joystick2.mType == Joystick.JoystickStatic)
		{
			joystick2.x = x;
		}
		
		else
		{
			if(joystick1.mType == Joystick.JoystickStatic)
			{
				joystick1.x = x;
			}
			
			if(joystick2.mType == Joystick.JoystickStatic)
			{
				joystick2.x = x;
			}
		}
	}
	
	public static function setY(joystick:Int, y:Float)
	{
		y = Std.int(y);
		
		initialize();
	
		if(joystick == 1 && joystick1.mType == Joystick.JoystickStatic)
		{
			joystick1.y = y;
		}
		
		else if(joystick == 2 && joystick2.mType == Joystick.JoystickStatic)
		{
			joystick2.y = y;
		}
		
		else
		{
			if(joystick1.mType == Joystick.JoystickStatic)
			{
				joystick1.y = y;
			}
			
			if(joystick2.mType == Joystick.JoystickStatic)
			{
				joystick2.y = y;
			}
		}
	}
	
	public static function enable(joystick:Int)
	{
		initialize();
	
		if(joystick == 1 && joystick1.mType == Joystick.JoystickStatic)
		{
			joystick1.show();
		}
		
		else if(joystick == 2 && joystick2.mType == Joystick.JoystickStatic)
		{
			joystick2.show();
		}
		
		else
		{
			if(joystick1.mType == Joystick.JoystickStatic)
			{
				joystick1.show();
			}
			
			if(joystick2.mType == Joystick.JoystickStatic)
			{
				joystick2.show();
			}
		}
	}

	public static function disable(joystick:Int)
	{
		initialize();
	
		if(joystick == 1 && joystick1.mType == Joystick.JoystickStatic)
		{
			joystick1.hide();
		}
		
		else if(joystick == 2 && joystick2.mType == Joystick.JoystickStatic)
		{
			joystick2.hide();
		}
		
		else
		{
			if(joystick1.mType == Joystick.JoystickStatic)
			{
				joystick1.hide();
			}
			
			if(joystick2.mType == Joystick.JoystickStatic)
			{
				joystick2.hide();
			}
		}
	}

	public static function getDirection(joystick:Int):Float
	{
		initialize();
	
		if(joystick == 1)
		{
			return joystick1.mDirection;
		}
		
		else
		{
			return joystick2.mDirection;
		}
	}
	
	public static function getDistance(joystick:Int):Float
	{
		initialize();
	
		if(joystick == 1)
		{
			return joystick1.mDistance;
		}
		
		else
		{
			return joystick2.mDistance;
		}
	}
	
	public static function createJoystick(target:Sprite, outer:BitmapData, inner:BitmapData, type:Int):Joystick
	{
		var j = new Joystick();
 		j.setOuterImage(new Bitmap(outer));
 		j.setInnerImage(new Bitmap(inner));
 		j.setType(type);
 		j.setInnerRadius(0);
 		j.setOuterRadius(40);
		target.addChild(j);
		j.hide();
		j.start();
		return j;
	}
}