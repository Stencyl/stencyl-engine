package behavior;

//Actual scripts extend from this
class Script 
{
	public function new() 
	{
		initAttributes();
		mountEvents();		
	}		

	public function initAttributes()
	{
	}

	public function mountEvents()
	{
		//Editor generates the junk here - can these refer to attributes though?!
		
		var updateEvent = function(elapsedTime:Float) 
		{ 
			
		};
		
		updateEvent(10);
	}
}
