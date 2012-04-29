package scripts;

import behavior.ActorScript;
import behavior.TimedTask;

import models.Actor;

class Motion extends ActorScript
{	
	private var event:Void->Void;
	public var n:Int;

	public function new(actor:Actor, engine:Engine) 
	{	
		super(engine);
		
		n = 2;
		
		event = function() 
		{ 
			//n = 3;
			//trace("heehaw");
			//trace("" + n);
			
			if(Input.check("left"))
			{
				actor.xSpeed = -0.2;
			}
			
			else if(Input.check("right"))
			{
				actor.xSpeed = 0.2;
			}
			
			else
			{
				actor.xSpeed = 0;
			}
			
			if(Input.check("up"))
			{
				actor.ySpeed = -0.2;
			}
			
			else if(Input.check("down"))
			{
				actor.ySpeed = 0.2;
			}
			
			else
			{
				actor.ySpeed = 0;
			}
			
			if(Input.mouseDown)
			{
				actor.x = Input.mouseX;
				actor.y = Input.mouseY;
			}
		};
	}		
	
	override public function init()
	{
		var f = function(task:TimedTask):Void 
		{ 
			trace("hawhee");
		};
	
		runLater(1000, f);
	}

	override public function update(elapsedTime:Float)
	{
		event();
	}
}
