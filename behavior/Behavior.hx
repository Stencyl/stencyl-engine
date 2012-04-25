package behavior;

class Behavior 
{	
	public var parent:Dynamic;
	public var engine:GameState;
	
	public var enabled:Bool;
	public var drawable:Bool;
	
	public var ID:Int;
	public var name:String;
	
	public var classname:String;
	public var cls:Type;
	public var script:Script;
	
	public var attributes:Array<Attribute>;

	public function new
	(
		parent:Dynamic,
		game:GameState,
		ID:Int,
		name:String,
		classname:String, 
		enabled:Bool, 
		drawable:Bool,
		attributes:Array<Attribute>
	)
	{
		this.parent = parent;
		this.engine = engine;
		this.classname = classname;
	
		if(game != null)
		{
			try
			{
				cls = Type.resolveClass(classname);
			}
			
			catch(e:Error)
			{
				trace("Could not load: " + classname);
			}
		}
		
		this.enabled = enabled;
		this.drawable = drawable;

		this.ID = ID;
		this.name = name;
		
		this.attributes = attributes;
	}	

	public function initScript(initJustScript:Bool = false)
	{
		if(cls == null)
		{
			trace("Could not initialize Script for Behavior: " + name);
			script = new SceneScript(engine);
			return;
		}
		
		script = Type.createInstance(cls, [parent, engine]);
		script.wrapper = this;
		initAttributes();
		
		if(!initJustScript)
		{
			try
			{
				script.init();
			}
			
			catch(e:Error)
			{
				trace("Error in when created for behavior: " + name);
				trace(e.getStackTrace());
			}
		}
	}
	
	private function initAttributes()
	{
		//TODO
		/*
		for each(var a:Attribute in attributes)
		{
			if(a.type == "actor" && a.fieldName == "actor" && script is ActorScript)
			{
				continue;
			}
			
			if(a.type == "actor" || a.type == "joint" || a.type == "region")
			{
				var eID:Number = a.getRealValue();
				
				if(a.type == "actor")
				{
					script[a.fieldName] = game.getActor(eID);
				}
				
				else if(a.type == "joint")
				{
					script[a.fieldName] = game.getJoint(eID);
				}
				
				else if(a.type == "region")
				{
					script[a.fieldName] = game.getRegion(eID);
				}
				
				else if (a.type == "terrainregion")
				{
					script[a.fieldName] = game.getTerrainRegion(eID);
				}
			}
			
			else if(a.type == "actorgroup")
			{
				var groupID:Number = a.getRealValue();
				script[a.fieldName] = game.getGroup(groupID);
			}
			
			else
			{
				var realValue:* = a.getRealValue();
				
				if(a.type == "list")
				{
					//?????
					if(realValue is XMLList)
					{
						var arr:Array = ActorTypeReader.readList(realValue as XMLList);
						script[a.fieldName] = arr;
					}
					
					else
					{
						script[a.fieldName] = realValue;
					}
				}
				
				else
				{
					script[a.fieldName] = realValue;
				}
				
				trace("Set att(" + a.fieldName + ") to " + realValue);
			}
		}*/
	}

	public function update(elapsedTime:Float)
	{
		if(script != null)
		{
			script.update();
		}
	}
	
	public function draw(g:Graphics, x:Int, y:Int)
	{
		if(script != null)
		{
			script.draw(g, x, y);	
		}
	}
	
	public function drawLayer(g:Graphics, x:Int, y:Int, layerID:Int)
	{
		if(script != null && Std.is(script, SceneScript))
		{
			script.drawLayer(g, x, y, layerID);	
		}
	}
}
