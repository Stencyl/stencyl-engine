package ;

interface AssetLoader
{
	function init(assets:Data, numLeft:Int = 0, state:Engine=null):Void;
	function initAssets(assets:Data):Void;
	function loadResources():Void;
	function loadScenes():Void;
}