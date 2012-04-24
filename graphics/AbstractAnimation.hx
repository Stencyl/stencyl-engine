package graphics;

interface AbstractAnimation 
{
	public function update(elapsedTime:Float):Void;
	public function getCurrentFrame():Int;
	public function reset():Void;
}
