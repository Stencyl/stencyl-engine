package [PACKAGENAME];

import com.stencyl.utils.Utils;
import com.stencyl.utils.ConfigUtil;

import haxe.xml.Access;

using StringTools;

class [CLASSNAME]
{
	[VARIABLES]

    private static var __defines = com.stencyl.utils.HaxeDefines.getDefines();
    private static var __initialized = false;
    private static var __reloadHandlers:Map<String, (oldValue:Dynamic, newValue:Dynamic)->Void>;

    public static function load():Void
    {
        var text = Utils.getConfigText("config/ext-[EXTENSION_ID].xml");
        loadFromString(text);
    }

    private static function loadFromString(text:String, handleReload:Bool = true):Void
    {
        var xml = new Access(Xml.parse(text).firstElement());
        var map = ConfigUtil.xmlToMap(xml, "name", "val");
        if(!__initialized)
        {
            __initialized = true;
            handleReload = false;
        }
        [SET_STATIC_FIELDS]
    }

    private static function addReloadHandler(property:String, handler:(oldValue:Dynamic, newValue:Dynamic)->Void)
    {
        __reloadHandlers.set(property, handler);
    }
}