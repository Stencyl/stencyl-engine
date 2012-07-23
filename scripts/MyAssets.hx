package scripts;

import haxe.xml.Fast;
import nme.Assets;
import com.stencyl.AssetLoader;

class MyAssets implements AssetLoader
{
	public static var landscape:Bool = true;
	public static var autorotate:Bool = true;
	public static var stageWidth:Int = 480;
	public static var stageHeight:Int = 320;
	public static var initSceneID:Int = 0;
	
	public function new()
	{
	}
	
	public function loadResources(resourceMap:Hash<Dynamic>):Void
	{
		resourceMap.set("1-0.png", Assets.getBitmapData("assets/graphics/1-0.png"));
		resourceMap.set("18-0.png", Assets.getBitmapData("assets/graphics/18-0.png"));
	}
	
	public function loadScenes(scenesXML:IntHash<Fast>, scenesTerrain:IntHash<Dynamic>):Void
	{
		scenesXML.set(0, new Fast(Xml.parse(Assets.getText("assets/data/scene-0.xml")).firstElement()));
		scenesTerrain.set(0, Assets.getBytes("assets/data/scene-0.scn"));
	}
}