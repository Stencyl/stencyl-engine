package behavior;

//Actual scripts extend from this
class Script 
{
	public var wrapper:Behavior;
	public var engine:GameState;
		
	public function new() 
	{
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
}
