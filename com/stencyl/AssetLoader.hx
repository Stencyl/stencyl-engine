package com.stencyl;

import com.stencyl.models.IdType;

interface AssetLoader
{
	function loadResources(resourceMap:Map<String,Dynamic>):Void;
	function loadScenes(scenesXML:Map<IdType,String>):Void;
}