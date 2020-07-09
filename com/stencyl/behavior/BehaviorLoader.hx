package com.stencyl.behavior;

#if stencyltools

import hscript.*;

#end

class BehaviorLoader
{
	public static var classCache:Map<String,Class<Dynamic>> = new Map<String,Class<Dynamic>>();

	public static function getClass(classname:String):Class<Dynamic>
	{
		if(!classCache.exists(classname))
		{
			try
			{
				classCache.set(classname, Type.resolveClass(classname));
			}
			catch(e:String)
			{
				trace("Could not load: " + classname);
				trace(e);
				return null;
			}
		}
		
		return classCache.get(classname);
	}
	
	public static function createInstance(name:String, type:String, classname:String, parent:Dynamic):Script
	{
		var cls = getClass(classname);
		var script:Script = null;
		
		if(cls == null)
		{
			trace("Could not init Behavior: " + name + " with " + classname);
			script = new SceneScript();
		}
		
		if(type == "actor")
		{
			if (Type.getClass(parent) == Engine)
			{
				trace("Actor behavior " + name + " failed to init because parent is scene.  Open and save the scene to resolve this error.");
				return new SceneScript();
			}
			script = Type.createInstance(cls, [0, parent, null]);
		}
		else
		{
			if (Type.getClass(parent) == com.stencyl.models.Actor)
			{
				trace("Scene behavior " + name + " failed to init because parent is actor.  Open and save the actor to resolve this error.");
				return new SceneScript();
			}
			script = Type.createInstance(cls, [0, null]);
		}
		
		return script;
	}

	#if stencyltools

	/*public static function updateClass(id:String, ...):Void
	{
		classCache.set(id, ...);
		
	}*/
	
	#end
}
