package models.scene;

class RegionDef
{
	public var x:Int;
	public var y:Int;
	//public var shape:b2Shape;
	public var shapes:Array<Dynamic>;
	
	public var ID:Number;
	public var name:String;
	public var shapeID:Number;
	
	public function RegionDef(shapes:Array<Dynamic>;, ID:Int, name:String, x:Int, y:Int, shapeID:Int=0)
	{
		this.x = x;
		this.y = y;
		
		this.shapes = shapes;
		//this.shape = this.shapes[0];
		this.ID = ID;
		this.name = name;
		this.shapeID = shapeID;
	}
}