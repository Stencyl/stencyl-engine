package com.stencyl.loader;

#if flash

import com.stencyl.utils.Utils;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;

class CustomSwfPreloader extends StencylPreloader
{
	private var clickArea:TextField;
	private var loader:Loader;
	
	public function new()
	{
		super();
	}

	public override function showPreloader()
	{
		adStarted();

		var data = Utils.getConfigBytes(Config.swfPreloader.swfLoc);
		loader = new Loader();
		var arr = data.getData();
		loader.loadBytes(arr);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded);
		addChild(loader);
		
		clickArea = new TextField();
		clickArea.selectable = false;
		clickArea.x = 0;
		clickArea.y = 0;
		clickArea.width = getWidth();
		clickArea.height = getHeight();
		
		addChild(clickArea);

		clickArea.addEventListener(MouseEvent.CLICK, startGame);
	}
	
	private function swfLoaded(event:Event) 
	{
		var config = Config.swfPreloader;

		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfLoaded);

		loader.content.width = config.swfWidth;
		loader.content.height = config.swfHeight;
		
		loader.content.scaleX = 1;
		loader.content.scaleY = 1;
		
		loader.content.x = config.swfX;
		loader.content.y = config.swfY;
	}
	
	private function startGame(event:Event)
	{
		clickArea.removeEventListener(MouseEvent.CLICK, startGame);
		removeChild(clickArea);
		
		adFinished();
	}
}

#end