package com.stencyl.models.scene;

import com.stencyl.models.scene.AutotileFormat;
import openfl.geom.Point;

class Autotile
{
	public static var NO_AUTOTILE_DATA = 0;
	
	public static var CORNER_TL = 0x01;
	public static var CORNER_TR = 0x02;
	public static var CORNER_BR = 0x04;
	public static var CORNER_BL = 0x08;
	public static var SIDE_L    = 0x10;
	public static var SIDE_T    = 0x20;
	public static var SIDE_R    = 0x40;
	public static var SIDE_B    = 0x80;
	
	/*
	public static var defaultFormat:AutotileFormat =
	{
		var corners = new Array<Corners>();
		
		for(autotileFlags in 0x00...0xFF + 1)
		{
			var topSide = (SIDE_T & autotileFlags) == SIDE_T;
			var bottomSide = (SIDE_B & autotileFlags) == SIDE_B;
			var leftSide = (SIDE_L & autotileFlags) == SIDE_L;
			var rightSide = (SIDE_R & autotileFlags) == SIDE_R;
			
			var tlCorner = (CORNER_TL & autotileFlags) == CORNER_TL && !topSide && !leftSide;
			var trCorner = (CORNER_TR & autotileFlags) == CORNER_TR && !topSide && !rightSide;
			var brCorner = (CORNER_BR & autotileFlags) == CORNER_BR && !bottomSide && !rightSide;
			var blCorner = (CORNER_BL & autotileFlags) == CORNER_BL && !bottomSide && !leftSide;
			
			var tlCoord = new Point();
			var trCoord = new Point();
			var blCoord = new Point();
			var brCoord = new Point();
			
			//Top left corner
			if(tlCorner) { tlCoord.x = 4; tlCoord.y = 0; }
			else
			{
				if(topSide) tlCoord.y = 2;
				else if(bottomSide) tlCoord.y = 6;
				else tlCoord.y = 4;
				
				if(leftSide) tlCoord.x = 0;
				else if(rightSide) tlCoord.x = 4;
				else tlCoord.x = 2;
			}
			
			//Top right corner
			if(trCorner) { trCoord.x = 5; trCoord.y = 0; }
			else
			{
				if(topSide) trCoord.y = 2;
				else if(bottomSide) trCoord.y = 6;
				else trCoord.y = 4;
				
				if(rightSide) trCoord.x = 5;
				else if(leftSide) trCoord.x = 1;
				else trCoord.x = 3;
			}
			
			//Bottom left corner
			if(blCorner) { blCoord.x = 4; blCoord.y = 1; }
			else
			{
				if(bottomSide) blCoord.y = 7;
				else if(topSide) blCoord.y = 3;
				else blCoord.y = 5;
				
				if(leftSide) blCoord.x = 0;
				else if(rightSide) blCoord.x = 4;
				else blCoord.x = 2;
			}
			
			//Bottom right corner
			if(brCorner) { brCoord.x = 5; brCoord.y = 1; }
			else
			{
				if(bottomSide) brCoord.y = 7;
				else if(topSide) brCoord.y = 3;
				else brCoord.y = 5;
				
				if(rightSide) brCoord.x = 5;
				else if(leftSide) brCoord.x = 1;
				else brCoord.x = 3;
			}
			
			corners[autotileFlags] = new Corners(tlCoord, trCoord, blCoord, brCoord);
		}
		
		new AutotileFormat("Default", 0, 3, 4, corners);
	}
	*/
}
