package scripts;

import nme.display.Sprite;
import nme.events.Event;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.MouseEvent;

/*

TODO

- Make it configurable from the toolset, hook into the NMML
- Splash Screen
- Site Lock
- Unlocked for Pro

*/

class Preloader extends Sprite
{
	private var barBorder:Sprite;
	private var bar:Sprite;
	private var barBackground:Sprite;
	private var background:Sprite;

	public function new()
	{
		super();
	
		//Site Lock & URL
		var siteLock = "www.jon.com";
		var lockURL = "http://www.mysite.com";
		var url = "http://www.google.com";
	
		//Background Color && Image
		var showSplash = true;
		var backgroundColor = 0x336699;
	
		background = new Sprite();
		background.graphics.beginFill(backgroundColor, 1);
		background.graphics.drawRect(0, 0, getWidth(), getHeight());
		addChild(background);
	
		var backgroundImage = new Bitmap(Assets.getBitmapData("assets/graphics/bg.png"));
		addChild(backgroundImage);
	
		//Bar
		var barBorderColor = 0x777777;
		var barBackgroundColor = 0xcccccc;
		var barColor = 0x993366;
	
		var borderThickness = 51;
		var width = 100;
		var height = 52;
	
		var offsetX = 0;
		var offsetY = 0;
	
		var x = getWidth() / 2 - (width) / 2 + offsetX;
		var y = getHeight() / 2 - (height) / 2 + offsetY;
	
		var barPadding = 0; //This is not configurable.
	
		//---
	
		barBorder = new Sprite();
		barBorder.graphics.lineStyle(borderThickness, barBorderColor);
		barBorder.graphics.drawRect(0, 0, width + borderThickness, height + borderThickness);
		barBorder.x = x - borderThickness/2;
		barBorder.y = y - borderThickness/2;
		addChild(barBorder);
	
		barBackground = new Sprite();
		barBackground.graphics.beginFill(barBackgroundColor, 1);
		barBackground.graphics.drawRect(0, 0, width - barPadding * 2, height - barPadding * 2);
		barBackground.x = x + barPadding;
		barBackground.y = y + barPadding;
		barBackground.scaleX = 1;
		addChild(barBackground);
	
		bar = new Sprite();
		bar.graphics.beginFill(barColor, 0.35);
		bar.graphics.drawRect(0, 0, width - barPadding * 2, height - barPadding * 2);
		bar.x = x + barPadding;
		bar.y = y + barPadding;
		bar.scaleX = 0;
		addChild(bar);
	
		bar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 2);
	}
	
	public function onMouseDown(e:MouseEvent)
	{
		trace("bonco!");
		nme.Lib.getURL(new nme.net.URLRequest("http://www.google.com"));
	}
	
	public function getBackgroundColor():Int
	{
		return 0x336699;
	}
	
	public function getHeight():Float
	{
		return 480;
	}
	
	public function getWidth():Float
	{
		return 320;
	}
	
	public function onInit()
	{
	}
	
	public function onLoaded()
	{
		dispatchEvent (new Event (Event.COMPLETE));
	}
	
	public function onUpdate(bytesLoaded:Int, bytesTotal:Int)
	{
		var percentLoaded = bytesLoaded / bytesTotal;
	
		if(percentLoaded > 1)
		{
			percentLoaded == 1;
		}
	
		bar.scaleX = percentLoaded;
	}
}