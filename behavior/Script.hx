package behavior;

import nme.display.Graphics;

//Actual scripts extend from this
class Script 
{
	public var wrapper:Behavior;
	public var engine:Engine;
		
	public function new(engine:Engine) 
	{
		this.engine = engine;
	
		init();
		mountEvents();		
	}		
	
	//*-----------------------------------------------
	//* Basics
	//*-----------------------------------------------

	public function init()
	{
	}
	
	public function update(elapsedTime:Float)
	{
	}
	
	public function draw(g:Graphics, x:Int, y:Int)
	{
	}
	
	//*-----------------------------------------------
	//* Event Registration
	//*-----------------------------------------------

	public function mountEvents()
	{
		//Editor generates the junk here - can these refer to attributes though?!
		
		var updateEvent = function(elapsedTime:Float) 
		{ 
			
		};
		
		updateEvent(10);
	}
	
	//*-----------------------------------------------
	//* Timed Tasks
	//*-----------------------------------------------
	
	/**
	 * Runs the given function after a delay.
	 *
	 * @param	delay		Delay in execution (in milliseconds)
	 * @param	toExecute	The function to execute after the delay
	 */
	public function runLater(delay:Int, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, delay, false, actor);
		engine.addTask(t);

		return t;
	}
	
	/**
	 * Runs the given function periodically (every n seconds).
	 *
	 * @param	interval	How frequently to execute (in milliseconds)
	 * @param	toExecute	The function to execute after the delay
	 */
	public function runPeriodically(interval:Int, toExecute:TimedTask->Void, actor:Actor = null):TimedTask
	{
		var t:TimedTask = new TimedTask(toExecute, interval, true, actor);
		engine.addTask(t);
		
		return t;
	}
}
