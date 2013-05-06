package;

import com.stencyl.Engine;
import com.stencyl.utils.Utils;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.events.Event;
import nme.events.TouchEvent;

//Ported and adapted from
//http://wiki.sparrow-framework.org/users/shilo/extensions/shthumbstick

class Joystick extends Sprite
{
	public static var EVENT_TOUCH:String = "thumbstickTouch";
	public static var EVENT_MOVE:String = "thumbstickMove";
	public static var EVENT_TOUCHUP:String = "thumbstickTouchUp";
	public static var EVENT_CHANGED:String = "thumbstickChanged";

	public static var DEFAULT_TOUCHRADIUS:Float = 50.0;
	public static var DEFAULT_OUTERRADIUS:Float = 50.0;
	public static var DEFAULT_INNERRADIUS:Float = 25.0;
	
	public static var JoystickStatic:Int = 0;
    public static var JoystickRelative:Int = 1;
    public static var JoystickAbsolute:Int = 2;
    public static var JoystickFloat:Int = 3;

	public var mOuterImage:Bitmap;
	public var mInnerImage:Bitmap;

	public var mType:Int;
	public var mTouchRadius:Float;
	public var mOuterRadius:Float;
	public var mInnerRadius:Float;
	
	public var mBounds:Rectangle;
	public var mRender:Bool;
	
	public var mCurTouch:Int;
	
	public var mRelativeX:Float;
	public var mRelativeY:Float;
	
	public var mInnerImageScaleOnTouch:Float;
	
	public var mDistance:Float;
	public var mDirection:Float;
	
	public function new() 
	{
		super();
		
		mRender = false;
		mType = JoystickStatic;
		mTouchRadius = DEFAULT_TOUCHRADIUS;
		mOuterRadius = DEFAULT_OUTERRADIUS;
		mInnerRadius = DEFAULT_INNERRADIUS;
		mBounds = null;
		mInnerImageScaleOnTouch = 1.0;
		
		mDistance = 0;
		mDirection = 0;
	}
	
	public function start()
	{
		if(mRender) 
		{
			return;
		}
		
		Engine.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
	    Engine.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
        Engine.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
	
		mRender = true;
	}
	
	public function stop()
	{
		if(!mRender) 
		{
			return;
		}
		
		Engine.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
	    Engine.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
        Engine.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);

		mRender = false;
	}
	
	//---
	
	public function setOuterImage(outerImage:Bitmap)
	{
		if(mOuterImage != null) 
		{
			removeChild(mOuterImage);
		}
		
		mOuterImage = outerImage;
		addChild(mOuterImage);
		setChildIndex(mOuterImage, 0);

		mOuterRadius = (mOuterImage.width > mOuterImage.height) ? mOuterImage.width/2 : mOuterImage.height/2;
		positionContent();
	}
	
	public function setInnerImage(innerImage:Bitmap)
	{
		if(mInnerImage != null) 
		{
			removeChild(mInnerImage);
		}
		
		mInnerImage = innerImage;
		addChild(mInnerImage);
	
		mInnerRadius = (mInnerImage.width > mInnerImage.height) ? mInnerImage.width/2 : mInnerImage.height/2;
		positionContent();
	}
	
	public function setType(type:Int)
	{
		if(type != mType) 
		{
			mType = type;
			
			if(mType == JoystickStatic || mType == JoystickRelative)
			{
				setBounds(null);
				show();
			}
			
			else if(mType == JoystickAbsolute || mType == JoystickFloat)
			{
				setBounds(new Rectangle(0, 0, scripts.MyAssets.stageWidth * Engine.SCALE, scripts.MyAssets.stageHeight * Engine.SCALE));
				hide();
			}
		}
	}
	
	public function setTouchRadius(touchRadius:Float)
	{
		if(touchRadius != mTouchRadius) 
		{
			mTouchRadius = touchRadius;
		}
	}
	
	public function setOuterRadius(outerRadius:Float)
	{
		if(outerRadius != mOuterRadius) 
		{
			mOuterRadius = outerRadius;
		}
	}
	
	public function setInnerRadius(innerRadius:Float)
	{
		if(innerRadius != mInnerRadius) 
		{
			mInnerRadius = innerRadius;
		}
	}
	
	public function setBounds(bounds:Rectangle)
	{
		mBounds = bounds;
	}
	
	public function positionContent()
	{
		var outerRadius:Float = (mOuterRadius > mOuterImage.width/2) ? (mOuterRadius > mOuterImage.height/2) ? mOuterRadius : mOuterImage.height/2 : mOuterImage.width/2;

		if(mOuterImage != null) 
		{
			mOuterImage.x = outerRadius - mOuterImage.width/2;
			mOuterImage.y = outerRadius - mOuterImage.height/2;
		}
		
		if(mInnerImage != null)
		{
			mInnerImage.x = outerRadius - mInnerImage.width/2;
			mInnerImage.y = outerRadius - mInnerImage.height/2;
		}
	}
	
	public function getWidth():Float
	{
		if(mOuterRadius * 2 > mOuterImage.width)
		{
			return mOuterRadius * 2;
		}
		
		else
		{
			return mOuterImage.width;
		}
	}
	
	public function getHeight():Float
	{
		if(mOuterRadius * 2 > mOuterImage.height) 
		{
			return mOuterRadius * 2;
		} 
		
		else 
		{
			return mOuterImage.height;
		}
	}
	
	public function getCenterX():Float
	{
		return x + getWidth()/2;
	}
	
	public function getCenterY():Float
	{
		return y + getHeight()/2;
	}
	
	public function setCenterX(centerX:Float)
	{
		x = centerX - getWidth()/2;
	}
	
	public function setCenterY(centerY:Float)
	{
		y = centerY - getHeight()/2;
	}
	
	public function show()
	{
		if(mInnerImage != null)
		{
			mInnerImage.visible = true;
		}
		
		if(mOuterImage != null)
		{
			mOuterImage.visible = true;
		}
	}
	
	public function hide()
	{
		if(mInnerImage != null)
		{
			mInnerImage.visible = false;
		}
		
		if(mOuterImage != null)
		{
			mOuterImage.visible = false;
		}
		
		if(mType == JoystickAbsolute || mType == JoystickFloat)
		{	
			x = 0;
			y = 0;
		}
	}
	
	public function isWithinBounds(point:Point):Bool
	{
		if(point.x < mBounds.x || point.x > mBounds.x + mBounds.width || point.y < mBounds.y || point.y > mBounds.y + mBounds.height) 
		{
			return false;
		} 
		
		else 
		{
			return true;
		}
	}
	
	public function sendEvent(type:String, distance:Float, direction:Float)
	{
		if(direction < 0)
		{
			direction += 360;
		}
		
		mDistance = distance;
		mDirection = direction;
		
		//I rather just do polling.
		//dispatchEvent(new JoystickEvent(type, distance, direction));
		//dispatchEvent(new JoystickEvent(EVENT_CHANGED, distance, direction));
	}
	
	//---
	
	private function onTouchBegin(e:TouchEvent)
	{
		if(mType == JoystickStatic)
		{
			onStaticTouch(e);
		}
		
		else if(mType == JoystickRelative)
		{
			onRelativeTouch(e);
		}
		
		else if(mType == JoystickAbsolute)
		{
			onAbsoluteTouch(e);
		}
		
		else if(mType == JoystickFloat)
		{
			onAbsoluteTouch(e);
		}
	}
	
	private function onStaticTouch(e:TouchEvent)
	{
		var touchPosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(touchPosition.x - centerX), 2) + Math.pow(Math.abs(touchPosition.y - centerY), 2));
		
		if(distance > mTouchRadius) 
		{
			return;
		}
	
		mCurTouch = e.touchPointID;
		
		var radians:Float = Math.atan2(centerX - touchPosition.x, centerY - touchPosition.y);
		
		if(distance > mOuterRadius - mInnerRadius) 
		{
			distance = mOuterRadius - mInnerRadius;	
			
			if(mInnerImage != null) 
			{
				mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
				mInnerImage.x = (centerX - mInnerImage.width/2) - Math.sin(radians) * (mOuterRadius - mInnerRadius);
				mInnerImage.y = (centerY - mInnerImage.height/2) - Math.cos(radians) * (mOuterRadius - mInnerRadius);
			}
		} 
		
		else 
		{
			if(mInnerImage != null) 
			{
				mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
				mInnerImage.x = touchPosition.x - (mInnerImage.width/2);
				mInnerImage.y = touchPosition.y - (mInnerImage.height/2);
			}
		}
		
		sendEvent(EVENT_TOUCH, distance / (mOuterRadius - mInnerRadius), Utils.DEG * -radians);
	}
	
	private function onRelativeTouch(e:TouchEvent)
	{
		var touchPosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(touchPosition.x - centerX), 2) + Math.pow(Math.abs(touchPosition.y - centerY), 2));
		
		if(distance > mTouchRadius) 
		{
			return;
		}
		
		mCurTouch = e.touchPointID;
		
		mRelativeX = touchPosition.x;
		mRelativeY = touchPosition.y;
		
		if(mInnerImage != null) 
		{
			mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
			mInnerImage.x = centerX - mInnerImage.width / 2;
			mInnerImage.y = centerY - mInnerImage.height / 2;
		}
		
		sendEvent(EVENT_TOUCH, 0, 0);
	}
	
	private function onAbsoluteTouch(e:TouchEvent)
	{
		var touchPosition = new Point(e.stageX - x, e.stageY - y);
		
		if(!isWithinBounds(touchPosition)) 
		{
			return;
		}
		
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		
		mCurTouch = e.touchPointID;
		
		if(mInnerImage != null) 
		{
			mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
			mInnerImage.x = centerX - mInnerImage.width / 2;
			mInnerImage.y = centerY - mInnerImage.height / 2;
		}
		
		setCenterX(touchPosition.x);
		setCenterY(touchPosition.y);

		show();
		sendEvent(EVENT_TOUCH, 0, 0);
	}
	
	//---
	
	private function onTouchMove(e:TouchEvent)
	{
		if(e.touchPointID != mCurTouch)
		{
			return;
		}
		
		if(mType == JoystickStatic)
		{
			onStaticMove(e);
		}
		
		else if(mType == JoystickRelative)
		{
			onRelativeMove(e);
		}
		
		else if(mType == JoystickAbsolute)
		{
			onAbsoluteMove(e);
		}
		
		else if(mType == JoystickFloat)
		{
			onFloatMove(e);
		}
	}
	
	private function onStaticMove(e:TouchEvent)
	{
		var movePosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(movePosition.x - centerX), 2) + Math.pow(Math.abs(movePosition.y - centerY), 2));
		var radians:Float = Math.atan2(centerX - movePosition.x, centerY - movePosition.y);
		
		if(distance > mOuterRadius - mInnerRadius) 
		{
			distance = mOuterRadius - mInnerRadius;
			
			if(mInnerImage != null)
			{
				mInnerImage.x = (centerX - mInnerImage.width/2) - Math.sin(radians) * (mOuterRadius - mInnerRadius);
				mInnerImage.y = (centerY - mInnerImage.height/2) - Math.cos(radians) * (mOuterRadius - mInnerRadius);
			}
		} 
		
		else 
		{
			if(mInnerImage != null) 
			{
				mInnerImage.x = movePosition.x - (mInnerImage.width / 2);
				mInnerImage.y = movePosition.y - (mInnerImage.height / 2);
			}
		}
		
		sendEvent(EVENT_MOVE, distance / (mOuterRadius - mInnerRadius), Utils.DEG * -radians);
	}
	
	private function onRelativeMove(e:TouchEvent)
	{
		var movePosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(movePosition.x - mRelativeX), 2) + Math.pow(Math.abs(movePosition.y - mRelativeY), 2));
		var radians:Float = Math.atan2(mRelativeX - movePosition.x, mRelativeY - movePosition.y);
		
		if(distance > mOuterRadius - mInnerRadius)
		{
			distance = mOuterRadius-mInnerRadius;
			
			if(mInnerImage != null) 
			{
				mInnerImage.x = (centerX - mInnerImage.width/2) - Math.sin(radians) * (mOuterRadius - mInnerRadius);
				mInnerImage.y = (centerY - mInnerImage.height/2) - Math.cos(radians) * (mOuterRadius - mInnerRadius);
			}
		} 
		
		else 
		{
			if(mInnerImage != null) 
			{
				mInnerImage.x = movePosition.x - mRelativeX - (mInnerImage.width / 2) + centerX;
				mInnerImage.y = movePosition.y - mRelativeY - (mInnerImage.height / 2) + centerY;
			}
		}
		
		sendEvent(EVENT_MOVE, distance / (mOuterRadius - mInnerRadius), Utils.DEG * -radians);
	}
	
	private function onAbsoluteMove(e:TouchEvent)
	{
		var movePosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(movePosition.x - centerX), 2) + Math.pow(Math.abs(movePosition.y - centerY), 2));
		var radians:Float = Math.atan2(centerX - movePosition.x, centerY - movePosition.y);
		
		if(distance > mOuterRadius - mInnerRadius) 
		{
			distance = mOuterRadius - mInnerRadius;
			
			if(mInnerImage != null)
			{
				mInnerImage.x = (centerX - mInnerImage.width/2) - Math.sin(radians) * (mOuterRadius - mInnerRadius);
				mInnerImage.y = (centerY - mInnerImage.height/2) - Math.cos(radians) * (mOuterRadius - mInnerRadius);
			}
		} 
		
		else 
		{
			if(mInnerImage != null) 
			{
				mInnerImage.x = movePosition.x - (mInnerImage.width / 2);
				mInnerImage.y = movePosition.y - (mInnerImage.height / 2);
			}
		}
		
		sendEvent(EVENT_MOVE, distance / (mOuterRadius - mInnerRadius), Utils.DEG * -radians);
	}
	
	private function onFloatMove(e:TouchEvent)
	{
		var movePosition = new Point(e.stageX - x, e.stageY - y);
		var centerX:Float = getWidth() / 2;
		var centerY:Float = getHeight() / 2;
		var distance:Float = Math.sqrt(Math.pow(Math.abs(movePosition.x - centerX), 2) + Math.pow(Math.abs(movePosition.y - centerY), 2));
		var radians:Float = Math.atan2(centerX - movePosition.x, centerY - movePosition.y);
		
		if(distance > mOuterRadius - mInnerRadius) 
		{
			distance = mOuterRadius - mInnerRadius;
			
			var touchPosition = new Point(e.stageX - parent.x, e.stageY - parent.y);
			setCenterX(touchPosition.x + Math.sin(radians) * (mOuterRadius - mInnerRadius));
			setCenterY(touchPosition.y + Math.cos(radians) * (mOuterRadius - mInnerRadius));
			
			if(getCenterX() < mBounds.x) 
			{
				setCenterX(mBounds.x);
			}
			
			else if(getCenterX() > mBounds.x + mBounds.width) 
			{
				setCenterX(mBounds.x + mBounds.width);
			}
			
			if(getCenterY() < mBounds.y) 
			{
				setCenterY(mBounds.y);
			}
			
			else if(getCenterY() > mBounds.y + mBounds.height) 
			{
				setCenterY(mBounds.y + mBounds.height);
			}
			
			if(mInnerImage != null) 
			{
				mInnerImage.x = (centerX - mInnerImage.width / 2) - Math.sin(radians) * (mOuterRadius - mInnerRadius);
				mInnerImage.y = (centerY - mInnerImage.height / 2) - Math.cos(radians) * (mOuterRadius - mInnerRadius);
			}
		} 
		
		else 
		{
			if(mInnerImage != null) 
			{
				mInnerImage.x = movePosition.x - (mInnerImage.width / 2);
				mInnerImage.y = movePosition.y - (mInnerImage.height / 2);
			}
		}
		
		sendEvent(EVENT_MOVE, distance / (mOuterRadius - mInnerRadius), Utils.DEG * -radians);
	}

	//---
	
	private function onTouchEnd(e:TouchEvent)
	{
		if(e.touchPointID != mCurTouch)
		{
			return;
		}
		
		if(mType == JoystickStatic || mType == JoystickRelative)
		{
			if(mInnerImage != null) 
			{
				mInnerImage.scaleX = mInnerImage.scaleY = 1.0;
				mInnerImage.x = (getWidth() - mInnerImage.width) / 2;
				mInnerImage.y = (getHeight() - mInnerImage.height) / 2;
			}
		}
		
		else if(mType == JoystickAbsolute || mType == JoystickFloat)
		{
			hide();
		}
		
		mCurTouch = -1;
		sendEvent(EVENT_TOUCHUP, 0, 0);
	}
}