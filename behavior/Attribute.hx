package behavior;

class Attribute 
{	
	public var ID:Int;
	public var fieldName:String;
	public var fullName:String;
	public var type:String;
	
	public var defaultValue:String;
	public var value:Dynamic;
	
	public var realValue:Dynamic;
	public var parent:Dynamic;
	
	public function new(ID:Int, fieldName:String, fullName:String, value:Dynamic, type:String, parent:Dynamic)
	{
		this.ID = ID;
		this.fieldName = fieldName;
		this.fullName = fullName;
		this.type = type;

		this.value = value;
		realValue = null;
	}
	
	public function getRealValue():Dynamic
	{
		return null;
		
		/*if(realValue == null)
		{
			if(type == "int")
			{
				realValue = parseInt(value);
			}
			
			else if(type == "float" || type == "number")
			{
				realValue = Number(value);
			}
			
			else if(type == "boolean")
			{
				realValue = (value == "true") ? true : false;
			}
			
			else if(type == "color")
			{
				if(value == null || value == "")
				{
					realValue = 0xFF000000;
				}
				
				else
				{
					var s:Array = value.split(",");
					
					var r:Number = parseInt(s[0]);
					var g:Number = parseInt(s[1]);
					var b:Number = parseInt(s[2]);
					var a:Number = parseInt(s[3]);
					
					realValue = (a << 24) | (r << 16) | (g << 8) | b;
				}
			}
			
			else if(type == "sound" || type == "actortype" || type == "font")
			{
				if(value != null)
				{
					if(value == "null")
					{
						realValue = null;
					}
					
					else
					{
						realValue = Assets.get().resources[parseInt(value)];
					}
				}
			}
			
			else if(type == "actorgroup")
			{
				//Script will pull the right group. Keep as int.
				realValue = parseInt(value);
			}
			
			else if(type == "control")
			{
				realValue = value;
			}
			
			else if(type == "effect")
			{
				realValue = value;
			}
			
			else if(type == "animation")
			{
				realValue = value;
			}
			
			else if(type == "game-attribute")
			{
				realValue = value;
			}
			
			else if(type == "scene")
			{
				realValue = Game.get().scenes[parseInt(value)];
			}
			
			else if(type == "text") 
			{
				realValue = value;
			}
			
			else if(type == "list")
			{
				realValue = value;
				
				if(value == null)
				{
					realValue = new Array();
				}	
			}
			
			else if(value != null && type == "actor")
			{
				if(value == "thisactor")
				{
					realValue = parent;
				}
				
				else
				{
					realValue = parseInt(value);
				}
			}
			
			else if(value != null && type == "joint")
			{
				realValue = parseInt(value);
			}
			
			else if(value != null && type == "region")
			{
				realValue = parseInt(value);
			}
		}
		
		return realValue;
		*/
	}
}
