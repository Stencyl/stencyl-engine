package com.stencyl;

import haxe.xml.Fast;

interface AssetLoader
{
	function loadResources(resourceMap:Hash<Dynamic>):Void;
	function loadScenes(scenesXML:IntHash<Fast>, scenesTerrain:IntHash<Dynamic>):Void;
}