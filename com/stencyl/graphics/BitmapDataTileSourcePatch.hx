#if macro

package com.stencyl.graphics;

import haxe.macro.Context;
import haxe.macro.Expr;

class BitmapDataTileSourcePatch
{
	//add field to BitmapData:
	//  private var __tileSource:com.stencyl.graphics.TileSource
	
	macro public static function patch():Array<Field>
	{
		var fields = Context.getBuildFields();
		var newField = {
			name: "__tileSource",
			doc: null,
			meta: [],
			access: [APrivate],
			kind: FVar(macro:com.stencyl.graphics.TileSource),
			pos: Context.currentPos()
		};
		fields.push(newField);
		return fields;
	}
}

#end