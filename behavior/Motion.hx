package behavior;

import Input;

class Motion extends ActorScript
{	
	private var event:Void->Void;
	public var n:Int;

	public function new(engine:Engine) 
	{	
		super(engine);
		
		n = 2;
		
		event = function() 
		{ 
			n = 3;
			trace("heehaw");
			trace("" + n);
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
