package scripts;

import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;

class Motion extends ActorScript
{	
	private var event:Void->Void;
	public var n:Int;

	public function new(dummy:Int, actor:Actor, engine:Engine) 
	{	
		super(actor, engine);
		
		n = 2;
		
		var evt = function(elapsedTime:Float, junk:Array<Dynamic>) 
		{ 
			//actor.ySpeed = 0.02;
			
			if(actor.y >= 17)
			{
				return;
			}
		
			if(Input.check("left"))
			{
				//actor.xSpeed = -0.2;
				actor.moveActorBy(-1, 0, [3]);
			}
			
			else if(Input.check("right"))
			{
				//actor.xSpeed = 0.2;
				actor.moveActorBy(1, 0, [3]);
			}
			
			else
			{
				actor.xSpeed = 0;
			}
			
			if(Input.check("up"))
			{
				//actor.ySpeed = -0.2;
			}
			
			else if(Input.check("down"))
			{
				//actor.ySpeed = 0.2;
			}
			
			else
			{
				//actor.ySpeed = 0;
			}
			
			if(Input.mouseDown)
			{
				actor.x = Input.mouseX;
				actor.y = Input.mouseY;
			}
		};
		
		addWhenUpdatedListener(actor, evt);
	}		
	
	override public function init()
	{
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		
		var f = function(task:TimedTask):Void 
		{ 
			trace(getGameAttribute("yoshi"));
		};
	
		runLater(1000, function(task:TimedTask):Void {});
		
		setGameAttribute("yoshi", "dino");
		
		//saveGame("donkey2");
		//loadGame("donkey2");
	}

	override public function update(elapsedTime:Float)
	{
	}
}
