package com.stencyl.loader;

#if(flash || html5)
class PreloaderConfig
{
	public function new()
	{

	}

	public function setFields(data:Dynamic)
	{
		lockURL = data.lockURL;
		authorURL = data.authorURL;
		backgroundColor = data.backgroundColor;
		backgroundImage = data.backgroundImage;
		badgeImage = data.badgeImage;
		borderThickness = data.borderThickness;
		borderColor = data.borderColor;
		barLocation = data.barLocation;
		barWidth = data.barWidth;
		barHeight = data.barHeight;
		barColor = data.barColor;
		barOffsetX = data.barOffsetX;
		barOffsetY = data.barOffsetY;
		barBackgroundColor = data.barBackgroundColor;
	}

	public var lockURL:String;
	public var authorURL:String;

	public var backgroundColor:Int;
	public var backgroundImage:String;
	public var badgeImage:String;
	
	public var borderThickness:Int;
	public var borderColor:Int;
	public var barLocation:Int;
	public var barWidth:Int;
	public var barHeight:Int;
	public var barColor:Int;
	public var barOffsetX:Int;
	public var barOffsetY:Int;
	public var barBackgroundColor:Int;
}
#end