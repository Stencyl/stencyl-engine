package com.stencyl.models;

import com.stencyl.Engine;
import com.stencyl.utils.Assets;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.events.Event;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;

import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

class Joystick extends Sprite
{
    public static var joystickMap:Map<Int, Joystick>;
    
    public static function resetStatics():Void
    {
        joystickMap = null;
        fixedCenter = 0;
        showWherePressed = 1;
        viewOffsetX = viewOffsetY = 0;
        initialized = false;
    }

    public var center:Point;
    public var outerRadius:Float;
    public var innerRadius:Float;
    public var joystickBounds:Rectangle;
    
    private var joystickTouchID: Int;

    public var id:Int;
    public var joystickDistance:Float = 0;
    public var joystickDirection:Float = 0;
    public var joystickDefaultDirection:Float = 0;

    public var joystickType:Int = 0;
    public static var fixedCenter:Int = 0;
    public static var showWherePressed:Int = 1;
    public var hideWhenReleased:Bool = false;
    
    public var outerImage:Bitmap = null;
	public var innerImage:Bitmap = null;
    
    public var outerAlphaWhenReleased:Float = 1;
    public var outerAlphaWhenPressed:Float = 1;
    public var innerAlphaWhenReleased:Float = 1;
    public var innerAlphaWhenPressed:Float = 1;
    
    public var isPressed:Bool = false;
    
    private static var viewOffsetX:Int = 0;
    private static var viewOffsetY:Int = 0;
    private static var initialized:Bool = false;

    public function new()
    {
        super();
    }

    private function start()
    {
        if(!initialized)
        {
            initialized = true;

            joystickMap = new Map();
            
            viewOffsetX = (Engine.screenOffsetX);
            viewOffsetY = (Engine.screenOffsetY);
        }
        
        #if (mobile || html5)
        
        if (Multitouch.supportsTouchEvents)
        {
            Engine.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            Engine.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            Engine.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
        }

        else
        {
            Engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            Engine.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        #else

        Engine.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        Engine.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        Engine.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        
        #end
    }

    private function stop()
	{
		if (Multitouch.supportsTouchEvents)
		{
			Engine.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			Engine.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			Engine.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}

		else
		{
			Engine.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Engine.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Engine.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		joystickMap = null;
	}
    
    private function onTouchBegin(e:TouchEvent)
	{
		onBegin(e.stageX, e.stageY, e.touchPointID);
	}

	private function onTouchMove(e:TouchEvent)
	{
		onMove(e.stageX, e.stageY, e.touchPointID);
	}

	private function onTouchEnd(e:TouchEvent)
	{
		onEnd(e.stageX, e.stageY, e.touchPointID);
	}

	private function onMouseDown(e:MouseEvent)
	{
		onBegin(e.stageX, e.stageY, 0);
	}

	private function onMouseMove(e:MouseEvent)
	{
		onMove(e.stageX, e.stageY, 0);
	}

	private function onMouseUp(e:MouseEvent)
	{
		onEnd(e.stageX, e.stageY, 0);
	}

    private function onBegin(x:Float, y:Float, currentTouch:Int)
	{
        if(joystickTouchID != -1)
        {
            return;
        }
        
        x = (x - viewOffsetX) / Engine.screenScaleX;
        y = (y - viewOffsetY) / Engine.screenScaleY;
        
        outerImage.alpha = outerAlphaWhenPressed;
        innerImage.alpha = innerAlphaWhenPressed;

        if(joystickType == fixedCenter)
        {
            var distance = Math.sqrt(Math.pow((center.x - x), 2) + Math.pow((center.y - y), 2));
            var radians = Math.atan2(center.y - y, center.x - x);
            
            if(distance > outerRadius)
            {
                return;
            }
            
            else if(distance > outerRadius - innerRadius)
            {
                distance = outerRadius - innerRadius;
                innerImage.x = center.x - Math.cos(radians) * (outerRadius - innerRadius) - innerImage.width * 0.5;
                innerImage.y = center.y - Math.sin(radians) * (outerRadius - innerRadius) - innerImage.height * 0.5;
            }
            
            else
            {
                innerImage.x = x - innerImage.width * 0.5;
                innerImage.y = y - innerImage.height * 0.5;
            }
			
			isPressed = true;
            
            joystickTouchID = currentTouch;
            joystickDistance = distance / (outerRadius - innerRadius);
            joystickDirection = radians * 180 / 3.1415926535 + 180;
        }

        else if(joystickType == showWherePressed)
        {
            if(x < joystickBounds.x || x > joystickBounds.x + joystickBounds.width || y < joystickBounds.y || y > joystickBounds.y + joystickBounds.height)
            {
                return;
            }
			
			isPressed = true;
            
            center.x = x;
            center.y = y;
            
            outerImage.x = center.x - outerImage.width * 0.5;
            outerImage.y = center.y - outerImage.height * 0.5;
            innerImage.x = center.x - innerImage.width * 0.5;
            innerImage.y = center.y - innerImage.height * 0.5;
            
            if(hideWhenReleased)
            {
                outerImage.visible = true;
                innerImage.visible = true;
            }

            joystickTouchID = currentTouch;
        }
	}
    
    private function onMove(x:Float, y:Float, currentTouch:Int)
	{
        if(currentTouch != joystickTouchID)
        {
            return;
        }
        
        x = (x - viewOffsetX) / Engine.screenScaleX;
        y = (y - viewOffsetY) / Engine.screenScaleY;
        
        var distance = Math.sqrt(Math.pow((center.x - x), 2) + Math.pow((center.y - y), 2));
        var radians = Math.atan2(center.y - y, center.x - x);
        
        if(distance > (outerRadius - innerRadius))
        {
            distance = (outerRadius - innerRadius);
            innerImage.x = center.x - Math.cos(radians) * (outerRadius - innerRadius) - innerImage.width * 0.5;
            innerImage.y = center.y - Math.sin(radians) * (outerRadius - innerRadius) - innerImage.height * 0.5;
        }
        
        else
        {
            innerImage.x = x - innerImage.width * 0.5;
            innerImage.y = y - innerImage.height * 0.5;
        }
        
        joystickDistance = distance / (outerRadius - innerRadius);
        joystickDirection = radians * 180 / 3.1415926535 + 180;
	}
    
    private function onEnd(x:Float, y:Float, currentTouch:Int)
	{
        if(currentTouch != joystickTouchID)
        {
            return;
        }
        
        joystickTouchID = -1;
		
        isPressed = false;
        
        outerImage.alpha = outerAlphaWhenReleased;
        innerImage.alpha = innerAlphaWhenReleased;

        innerImage.x = center.x - innerImage.width * 0.5;
        innerImage.y = center.y - innerImage.height * 0.5;

        if(hideWhenReleased)
        {
            outerImage.visible = false;
            innerImage.visible = false;
        }
		
		joystickDistance = 0;
        joystickDirection = joystickDefaultDirection;
		
	}
    
    // --- Add/Remove Joystick functions
    
    public static function addJoystick(id:Int, x:Float, y:Float, type:Int = 0, boundsX:Float = 0, boundsY:Float = 0, boundsWidth:Float = 0, boundsHeight:Float = 0, hide:Bool = false)
    {
        if (joystickMap != null && joystickMap.exists(id))
        {
            removeJoystick(id);
        }
        
        var joystick = new Joystick();
        
        joystick.start();

        joystick.id = id;
        joystick.joystickTouchID = -1;
        joystick.joystickDistance = 0;
        joystick.joystickDirection = 0;
		joystick.joystickDefaultDirection = 0;
        joystick.joystickType = type;

        joystick.center = new Point(x * Engine.SCALE, y * Engine.SCALE);

        joystickMap.set(id, joystick);
        
        setJoystickImage(id, true, "outer-joystick");
        setJoystickImage(id, false, "inner-joystick");
        
        joystick.outerAlphaWhenPressed = 1;
        joystick.outerAlphaWhenReleased = 1;
        joystick.innerAlphaWhenPressed = 1;
        joystick.innerAlphaWhenReleased = 1;
        
        if(joystick.joystickType == showWherePressed)
        {
            joystick.joystickBounds = new Rectangle(boundsX * Engine.SCALE + viewOffsetX, boundsY * Engine.SCALE + viewOffsetY, boundsWidth * Engine.SCALE, boundsHeight * Engine.SCALE);
        }
        
        if(hide)
        {
            joystick.hideWhenReleased = true;
            joystick.outerImage.visible = false;
            joystick.innerImage.visible = false;
        }
    }
    
    public static function removeJoystick(id:Int)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            var target = Engine.engine.root;
            
            joystickMap.remove(id);
            
            target.removeChild(joystick.outerImage);
            target.removeChild(joystick.innerImage);
            
            joystick = null;
		}
    }
    
    /// --- Get Distance and Direction of Joystick

    public static function getJoystickDisDir(id:Int, distance:Bool = true):Float
    {
        var disdir:Float = 0;

        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            
            disdir = (distance) ? joystick.joystickDistance : joystick.joystickDirection;
		}

        return disdir;
    }
    
    /// --- Set/Get Center of Joystick
    
    public static function setJoystickCenter(id:Int, x:Float, y:Float)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            
            joystick.center = new Point(x * Engine.SCALE, y * Engine.SCALE);

            joystick.outerImage.x = joystick.center.x - joystick.outerImage.width * 0.5;
            joystick.outerImage.y = joystick.center.y - joystick.outerImage.height * 0.5;
            joystick.innerImage.x = joystick.center.x - joystick.innerImage.width * 0.5;
            joystick.innerImage.y = joystick.center.y - joystick.innerImage.height * 0.5;
		}
    }
    
    public static function getJoystickCenter(id:Int, x:Bool = true):Float
    {
        var centerXY:Float = 0;
        
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            
            centerXY = ((x) ? joystick.center.x : joystick.center.y) / Engine.SCALE;
		}
        
        return centerXY;
    }
    
    /// --- Set/Get Inner/Outer Radius of Jostick
    
    public static function setJoystickRadius(id:Int, outer:Bool = true, radius:Float)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            
            if(outer && joystick.outerRadius != radius * Engine.SCALE)
            {
                joystick.outerRadius = radius * Engine.SCALE;
            }

            else if(joystick.innerRadius != radius * Engine.SCALE)
            {
                joystick.innerRadius = radius * Engine.SCALE;
            }
		}
    }
    
    public static function getJoystickRadius(id:Int, outer:Bool = true):Float
    {
        var radius:Float = 0;
        
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);
            
            radius = ((outer) ? joystick.innerRadius : joystick.outerRadius) / Engine.SCALE;
		}
        
        return radius;
    }
    
    /// --- Other
    
    public static function alwaysHideRJ(id:Int)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);

            joystick.hideWhenReleased = true;
            joystick.outerImage.visible = false;
            joystick.innerImage.visible = false;
		}
    }
    
    public static function setDefaultDirection(id:Int, direction:Float)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);

            joystick.joystickDefaultDirection = direction;
            joystick.joystickDirection = direction;
		}
    }
    
    public static function isJoystickPressed(id:Int):Bool
    {
        if (joystickMap.exists(id))
        {
            var joystick = joystickMap.get(id);
            
            return joystick.isPressed;
        }
        
        return false;
    }
    
    /// --- Set/Get Touch Region properties
    
    public static function setTouchRegionForRJ(id:Int, boundsX:Float = 0, boundsY:Float = 0, boundsWidth:Float = 0, boundsHeight:Float = 0)
    {
        if (joystickMap.exists(id))
		{
			var joystick = joystickMap.get(id);

            if (joystick.joystickType == showWherePressed)
            {
                joystick.joystickBounds = new Rectangle(boundsX * Engine.SCALE + viewOffsetX, boundsY * Engine.SCALE + viewOffsetY, boundsWidth * Engine.SCALE, boundsHeight * Engine.SCALE);
            }
		}
    }
    
    public static function getTouchRegionPropertyForRJ(id:Int, property:Int):Float
    {
        if (joystickMap.exists(id))
        {
            var joystick = joystickMap.get(id);
            
            if (joystick.joystickType == showWherePressed)
            {
                if (property == 1) // Get touch region X
                {
                    return joystick.joystickBounds.x - viewOffsetX;
                }
                else if (property == 2) // Get touch region Y
                {
                    return joystick.joystickBounds.y - viewOffsetY;
                }
                else if (property == 3) // Get touch region width
                {
                    return joystick.joystickBounds.width / Engine.SCALE;
                }
                else // Get touch region Y
                {
                    return joystick.joystickBounds.height / Engine.SCALE;
                }
            }
        }

        return 0;
    }
    
    /// --- Joystick Images
    
    public static function setJoystickImage(id:Int, outerImage:Bool, imageName:String)
    {
        if (joystickMap.exists(id))
        {
            var joystick = joystickMap.get(id);
            var target = Engine.engine.root;
            var image:BitmapData = null;

            if(Engine.SCALE == 1)
            {
                image = Assets.getBitmapData("assets/data/" + imageName + ".png");
            }
            
            else if(Engine.SCALE == 1.5)
            {
                image = Assets.getBitmapData("assets/data/" + imageName + "@1.5x.png");
            }
            
            else if(Engine.SCALE == 2)
            {
                image = Assets.getBitmapData("assets/data/" + imageName + "@2x.png");
            }
            
            else
            {
                image = Assets.getBitmapData("assets/data/" + imageName + "@4x.png");
            }
            
            if (outerImage)
            {
                if (joystick.outerImage != null)
                {
                    target.removeChild(joystick.outerImage);
                }

                joystick.outerImage = (new Bitmap(image));
                joystick.outerImage.x = joystick.center.x - joystick.outerImage.width * 0.5;
                joystick.outerImage.y = joystick.center.y - joystick.outerImage.height * 0.5;
                target.addChild(joystick.outerImage);
                
                joystick.outerRadius = joystick.outerImage.width * 0.5;
            }
            else
            {
                if (joystick.innerImage != null)
                {
                    target.removeChild(joystick.innerImage);
                }

                joystick.innerImage = (new Bitmap(image));
                joystick.innerImage.x = joystick.center.x - joystick.innerImage.width * 0.5;
                joystick.innerImage.y = joystick.center.y - joystick.innerImage.height * 0.5;
                target.addChild(joystick.innerImage);

                joystick.innerRadius = joystick.outerRadius - joystick.innerImage.width * 0.5;
            }
        }
    }
    
    public static function setJoystickAlpha(id:Int, outer:Bool = true, imageAlpha:Float = 1, whenReleased:Bool = true)
    {
        if (joystickMap.exists(id))
        {
            var joystick = joystickMap.get(id);

            if (outer)
            {
                if (whenReleased)
                {
                    joystick.outerAlphaWhenReleased = imageAlpha;
                    joystick.outerImage.alpha = imageAlpha;
                }
                else
                {
                    joystick.outerAlphaWhenPressed = imageAlpha;
                }
            }
            else
            {
                if (whenReleased)
                {
                    joystick.innerAlphaWhenReleased = imageAlpha;
                    joystick.innerImage.alpha = imageAlpha;
                }
                else
                {
                    joystick.innerAlphaWhenPressed = imageAlpha;
                }
            }
        }
    }
}