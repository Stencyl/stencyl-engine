package scripts;

import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;

import com.stencyl.graphics.G;


class Motion extends ActorScript
{	
	private var event:Void->Void;
	public var n:Int;

	public function new(dummy:Int, actor:Actor, engine:Engine) 
	{	
		super(actor, engine);
		
		n = 2;
		
		//actor.setAngularVelocity(1);

		var evt = function(elapsedTime:Float, junk:Array<Dynamic>) 
		{ 
			//actor.ySpeed = 0.02;
			
			//getCamera().x++;
			
			if(actor.y >= 1)
			{
				//return;
			}
		
			if(Input.check("left"))
			{
				actor.setXVelocity(-10);
				//actor.moveActorBy(-1, 0, [3]);
			}
			
			else if(Input.check("right"))
			{
				actor.setXVelocity(10);
				//actor.moveActorBy(1, 0, [3]);
			}
			
			else
			{
				actor.setXVelocity(0);
			}
			
			if(Input.check("up"))
			{
				actor.setYVelocity(-10);
				//actor.moveActorBy(0, -1, [3]);
			}
			
			else if(Input.check("down"))
			{
				actor.setYVelocity(10);
				//actor.moveActorBy(0, 1, [3]);
			}
			
			else
			{
				actor.setYVelocity(0);
			}
			
			if(Input.mouseDown)
			{
				actor.x = Engine.stage.mouseX;
				actor.y = Engine.stage.mouseY;
			}
		};
		
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void 
		{
			if(wrapper.enabled)
			{
		        g.drawString("X =" + getScreenWidth(), 0, 0);
		        g.drawString("Y =" + getScreenHeight(), 0, 50);
		        g.fillRect(0, 0, 32, 32);
			}
		});

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
		setGameAttribute("list", [1,2,3]);
		
		//saveGame("donkey2");
		//loadGame("donkey2");
		
		actor.makeAlwaysSimulate();
	}
}
