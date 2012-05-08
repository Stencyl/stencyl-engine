package mochi.as3;

extern class MochiScores {
	function new() : Void;
	static var onCloseHandler : Dynamic;
	static var onErrorHandler : Dynamic;
	static function closeLeaderboard() : Void;
	static function getPlayerInfo(p1 : Dynamic, ?p2 : Dynamic) : Void;
	static function onClose(?p1 : Dynamic) : Void;
	static function requestList(p1 : Dynamic, ?p2 : Dynamic) : Void;
	static function scoresArrayToObjects(p1 : Dynamic) : Dynamic;
	static function setBoardID(p1 : String) : Void;
	static function showLeaderboard(?p1 : Dynamic) : Void;
	static function submit(p1 : Float, p2 : String, ?p3 : Dynamic, ?p4 : Dynamic) : Void;
}
