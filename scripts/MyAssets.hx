package scripts;

import haxe.xml.Fast;
import nme.Assets;
import com.stencyl.AssetLoader;

class MyAssets implements AssetLoader
{
	public function new()
	{
	}
	
	public function loadResources(resourceMap:Hash<Dynamic>):Void
	{
		resourceMap.set("1-0.png", Assets.getBitmapData("assets/graphics/1-0.png"));
	}
	
	public function loadScenes(scenesXML:IntHash<Fast>, scenesTerrain:IntHash<Dynamic>):Void
	{
		scenesXML.set(0, new Fast(Xml.parse(Assets.getText("assets/data/scene-0.xml")).firstElement()));
		//scenesTerrain[0] = scene0b;
	}
}