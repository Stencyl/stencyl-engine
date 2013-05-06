package scripts;

import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;

import com.stencyl.graphics.G;

//A test behavior
class Motion extends ActorScript
{	
	private var event:Void->Void;

	public function new(dummy:Int, actor:Actor, engine:Engine) 
	{	
		super(actor, engine);

		var evt = function(elapsedTime:Float, junk:Array<Dynamic>) 
		{ 
			if(Input.check("left"))
			{
				actor.setXVelocity(-10);
			}
			
			else if(Input.check("right"))
			{
				actor.setXVelocity(10);
			}
			
			else
			{
				actor.setXVelocity(0);
			}
			
			if(Input.check("up"))
			{
				actor.setYVelocity(-10);
			}
			
			else if(Input.check("down"))
			{
				actor.setYVelocity(10);
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
		        
			}
		});
	}		
	
	override public function init()
	{
		showMobileAd();
	
		Input.define("left", [Key.A, Key.LEFT]);
		Input.define("right", [Key.D, Key.RIGHT]);
		Input.define("up", [Key.W, Key.UP]);
		Input.define("down", [Key.S, Key.DOWN]);
		
		var f = function(task:TimedTask):Void 
		{ 
			trace(getGameAttribute("yoshi"));
		};
	
		runLater(1000, function(task:TimedTask):Void {});
		
		setGameAttribute("yoshi", "is a dinosaur");
		setGameAttribute("list", [1,2,3]);
		
		actor.makeAlwaysSimulate();
	}
}
