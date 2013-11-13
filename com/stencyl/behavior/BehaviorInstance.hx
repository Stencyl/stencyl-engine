package com.stencyl.behavior;

class BehaviorInstance 
{
	public var behaviorID:Int;
	public var values:Map<String,Dynamic>;
	public var enabled:Bool;
	
	public function new(behaviorID:Int, values:Map<String,Dynamic>)
	{
		this.behaviorID = behaviorID;
		this.values = values;
		this.enabled = true;
	}
}
