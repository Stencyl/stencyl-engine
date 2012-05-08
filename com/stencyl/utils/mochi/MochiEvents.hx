package mochi.as3;

extern class MochiEvents {
	function new() : Void;
	static var ACHIEVEMENTS_OWNED : String;
	static var ACHIEVEMENT_NEW : String;
	static var ALIGN_BOTTOM : String;
	static var ALIGN_BOTTOM_LEFT : String;
	static var ALIGN_BOTTOM_RIGHT : String;
	static var ALIGN_CENTER : String;
	static var ALIGN_LEFT : String;
	static var ALIGN_RIGHT : String;
	static var ALIGN_TOP : String;
	static var ALIGN_TOP_LEFT : String;
	static var ALIGN_TOP_RIGHT : String;
	static var ERROR : String;
	static var FORMAT_LONG : String;
	static var FORMAT_NONE : String;
	static var FORMAT_SHORT : String;
	static var GAME_ACHIEVEMENTS : String;
	static var IO_ERROR : String;
	static var IO_PENDING : String;
	static function addEventListener(p1 : String, p2 : Dynamic) : Void;
	static function endPlay() : Void;
	static function getAchievements(?p1 : Dynamic) : Void;
	static function getVersion() : String;
	static function removeEventListener(p1 : String, p2 : Dynamic) : Void;
	static function setNotifications(p1 : Dynamic) : Void;
	static function showAwards(?p1 : Dynamic) : Void;
	static function startPlay(?p1 : String) : Void;
	static function startSession(p1 : String) : Void;
	static function trackEvent(p1 : String, ?p2 : Dynamic) : Void;
	static function triggerEvent(p1 : String, p2 : Dynamic) : Void;
	static function unlockAchievement(p1 : Dynamic) : Void;
}
