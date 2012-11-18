package com.stencyl.event;

class NativeListener 
{
	private var metaType:Int;
	private var type:Int;
	private var fn:Dynamic;
		
	public function new(metaType:Int, type:Int, fn:Dynamic) 
	{	
		this.metaType = metaType;
		this.type = type;
		this.fn = fn;
	}

	public function checkEvents(q:EventMaster)
	{
		//check just the category we care about
		var list = q.eventTable.get(metaType);
		
		if(list != null)
		{
			for(event in list)
			{
				if(event.type == type)
				{
					if(metaType == EventMaster.TYPE_ADS)
					{
						fn();
					}
					
					else if(metaType == EventMaster.TYPE_PURCHASES)
					{
						fn(event.data1);
					}
					
					else if(metaType == EventMaster.TYPE_GAMECENTER)
					{
						fn(event.data1);
					}
					
					else if(metaType == EventMaster.TYPE_KEYBOARD)
					{
						fn(event.data1);
					}
				}
			}
		}
	}
}
