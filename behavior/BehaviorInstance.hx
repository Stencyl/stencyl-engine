package behavior;

class BehaviorInstance 
{
	public var behaviorID:Int;
	public var values:Array<Dynamic>;
	public var enabled:Bool;
	
	public function new(behaviorID:Int, values:Array<Dynamic>)
	{
		this.behaviorID = behaviorID;
		this.values = values;
		this.enabled = true;
	}
}
