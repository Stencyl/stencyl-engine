package ;

import behavior.TimedTask;

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
}
