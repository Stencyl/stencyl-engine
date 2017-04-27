package com.stencyl.models;

typedef IdType = Int

class IdUtils {
	public static var INVALID_ID = -1;

	public static function parseId(id: String): IdType {
		return Std.parseInt(id);
	}
}