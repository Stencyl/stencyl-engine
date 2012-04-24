package behavior;

import Input;

class Motion 
{	
	private var event:Void->Void;
	public var n:Int;

	public function new() 
	{	
		n = 2;
		
		event = function() 
		{ 
			n = 3;
			trace("heehaw");
			trace("" + n);
		};
	}		
	
	public function init()
	{
		
	}

	public function update()
	{
		event();
	}
}
