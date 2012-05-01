package ;

import behavior.Attribute;
import behavior.Behavior;
import behavior.TimedTask;
import behavior.BehaviorManager;
import behavior.BehaviorInstance;

class Engine 
{
	var tasks:Array<TimedTask>;

	public function new() 
	{		
		tasks = new Array<TimedTask>();
	}
	
	public function update(elapsedTime:Float) 
	{
		var i = 0;
		
		while(i < tasks.length)
		{
			var t:TimedTask = tasks[i];
			
			t.update(10);
			
			if(t.done)
			{
				tasks.remove(t);	
				i--;
			}
			
			i++;
		}
	}
	
	public function addTask(task:TimedTask)
	{
		tasks.push(task);
	}
	
	public function removeTask(taskToRemove:TimedTask)
	{
		tasks.remove(taskToRemove);
	}		
	
	public static function initBehaviors
	(
		manager:BehaviorManager, 
		behaviorValues:Hash<Dynamic>, 
		parent:Dynamic, 
		game:Engine,
		initialize:Bool
	)
	{
		if(behaviorValues == null)
		{
			return;
		}
		
		for(behaviorInstance in behaviorValues)
		{
			var bi:BehaviorInstance = behaviorInstance;
		
			if(bi == null || !bi.enabled)
			{
				continue;
			}
			
			var template:Behavior = Data.get().behaviors.get("" + bi.behaviorID);
			var attributes:Hash<Attribute> = new Hash<Attribute>();
			
			for(key in bi.values.keys())
			{
				var value:Dynamic = bi.values.get(key);
				
				if(template == null)
				{
					trace("Non-Existent Behavior ID (Init): " + bi.behaviorID);
					continue;
				}
				
				var attribute:Attribute = cast(template.attributes.get(key), Attribute);

				if(attribute == null)
				{
					continue;
				}
				
				var type:String = attribute.type;
				var ID:Int = attribute.ID;
				
				attributes.set(key, new Attribute(ID, attribute.fieldName, attribute.fullName, value, type, null));
			}
			
			if(template == null)
			{
				trace("Non-Existent Behavior ID (Init): " + bi.behaviorID);
				continue;
			}
			
			var b:Behavior = new Behavior
			(
				parent, 
				game, 
				template.ID, 
				template.name, 
				template.classname, 
				true, 
				false,  
				attributes
			);
			
			manager.add(b);
		}
		
		if(initialize)
		{
			manager.initScripts();
		}
	}
}
