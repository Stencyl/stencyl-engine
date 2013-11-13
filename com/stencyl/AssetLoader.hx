package com.stencyl;

import haxe.xml.Fast;

interface AssetLoader
{
	function loadResources(resourceMap:Map<String,Dynamic>):Void;
	function loadScenes(scenesXML:Map<Int,String>):Void;
}