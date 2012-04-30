package behavior;

class BehaviorInstance 
{
	public var behaviorID:Int;
	public var values:Hash<Dynamic>;
	public var enabled:Bool;
	
	public function new(behaviorID:Int, values:Hash<Dynamic>)
	{
		this.behaviorID = behaviorID;
		this.values = values;
		this.enabled = true;
	}
}
