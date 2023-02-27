package com.stencyl.loader;

import com.stencyl.utils.motion.*;
import com.stencyl.Engine;
import openfl.text.*;

#if stencyldemo

class SplashBox
{
	public function new()
	{
		var label:TextField = new TextField();
		var fnt:TextFormat = new TextFormat("Arial", 12);
		fnt.color = 0xFFFFFF;

		label.defaultTextFormat = fnt;
		label.text = "Stencyl - Trial Mode";
		label.background = true;
		label.backgroundColor = 0x333333;
		label.x = 0;
		label.y = 0;
		label.width = 120;
		label.height = 20;

		TweenManager.timer(100).doOnComplete(function() {
			Engine.engine.root.addChild(label);
		});
	}
}

#end