package com.stencyl;

import openfl.ui.Keyboard;

class Key
{
	public inline static var ANY = -1;
	
	public inline static var LEFT = 37;
	public inline static var UP = 38;
	public inline static var RIGHT = 39;
	public inline static var DOWN = 40;
	
	public inline static var ENTER = 13;
	public inline static var CONTROL = 17;
	public inline static var COMMAND = 15;
	public inline static var SPACE = 32;
	public inline static var SHIFT = 16;
	public inline static var BACKSPACE = 8;
	public inline static var CAPS_LOCK = 20;
	public inline static var DELETE = 46;
	public inline static var END = 35;
	public inline static var ESCAPE = 27;
	public inline static var HOME = 36;
	public inline static var INSERT = 45;
	public inline static var TAB = 9;
	public inline static var PAGE_DOWN = 34;
	public inline static var PAGE_UP = 33;
	public inline static var LEFT_SQUARE_BRACKET = 219;
	public inline static var RIGHT_SQUARE_BRACKET = 221;

#if flash
	public inline static var A = 65;
	public inline static var B = 66;
	public inline static var C = 67;
	public inline static var D = 68;
	public inline static var E = 69;
	public inline static var F = 70;
	public inline static var G = 71;
	public inline static var H = 72;
	public inline static var I = 73;
	public inline static var J = 74;
	public inline static var K = 75;
	public inline static var L = 76;
	public inline static var M = 77;
	public inline static var N = 78;
	public inline static var O = 79;
	public inline static var P = 80;
	public inline static var Q = 81;
	public inline static var R = 82;
	public inline static var S = 83;
	public inline static var T = 84;
	public inline static var U = 85;
	public inline static var V = 86;
	public inline static var W = 87;
	public inline static var X = 88;
	public inline static var Y = 89;
	public inline static var Z = 90;

#else
	public inline static var A = 97;
	public inline static var B = 98;
	public inline static var C = 99;
	public inline static var D = 100;
	public inline static var E = 101;
	public inline static var F = 102;
	public inline static var G = 103;
	public inline static var H = 104;
	public inline static var I = 105;
	public inline static var J = 106;
	public inline static var K = 107;
	public inline static var L = 108;
	public inline static var M = 109;
	public inline static var N = 110;
	public inline static var O = 111;
	public inline static var P = 112;
	public inline static var Q = 113;
	public inline static var R = 114;
	public inline static var S = 115;
	public inline static var T = 116;
	public inline static var U = 117;
	public inline static var V = 118;
	public inline static var W = 119;
	public inline static var X = 120;
	public inline static var Y = 121;
	public inline static var Z = 122;
#end
	
	public inline static var F1 = 112;
	public inline static var F2 = 113;
	public inline static var F3 = 114;
	public inline static var F4 = 115;
	public inline static var F5 = 116;
	public inline static var F6 = 117;
	public inline static var F7 = 118;
	public inline static var F8 = 119;
	public inline static var F9 = 120;
	public inline static var F10 = 121;
	public inline static var F11 = 122;
	public inline static var F12 = 123;
	public inline static var F13 = 124;
	public inline static var F14 = 125;
	public inline static var F15 = 126;
	
	public inline static var DIGIT_0 = 48;
	public inline static var DIGIT_1 = 49;
	public inline static var DIGIT_2 = 50;
	public inline static var DIGIT_3 = 51;
	public inline static var DIGIT_4 = 52;
	public inline static var DIGIT_5 = 53;
	public inline static var DIGIT_6 = 54;
	public inline static var DIGIT_7 = 55;
	public inline static var DIGIT_8 = 56;
	public inline static var DIGIT_9 = 57;
	
	public inline static var NUMPAD_0 = 96;
	public inline static var NUMPAD_1 = 97;
	public inline static var NUMPAD_2 = 98;
	public inline static var NUMPAD_3 = 99;
	public inline static var NUMPAD_4 = 100;
	public inline static var NUMPAD_5 = 101;
	public inline static var NUMPAD_6 = 102;
	public inline static var NUMPAD_7 = 103;
	public inline static var NUMPAD_8 = 104;
	public inline static var NUMPAD_9 = 105;
	public inline static var NUMPAD_ADD = 107;
	public inline static var NUMPAD_DECIMAL = 110;
	public inline static var NUMPAD_DIVIDE = 111;
	public inline static var NUMPAD_ENTER = 108;
	public inline static var NUMPAD_MULTIPLY = 106;
	public inline static var NUMPAD_SUBTRACT = 109;
	
	/**
	 * Returns the name of the key.
	 * @param	char		The key to name.
	 * @return	The name.
	 */
	public static function nameOfKey(char):String
	{
		if (char >= A && char <= Z) return String.fromCharCode(char);
		if (char >= F1 && char <= F15) return "F" + Std.string(char - 111);
		if (char >= 96 && char <= 105) return "NUMPAD " + Std.string(char - 96);
		switch (char)
		{
			case LEFT:  return "LEFT";
			case UP:    return "UP";
			case RIGHT: return "RIGHT";
			case DOWN:  return "DOWN";
				
			case ENTER:     return "ENTER";
			case CONTROL:   return "CONTROL";
			case COMMAND:   return "COMMAND";
			case SPACE:     return "SPACE";
			case SHIFT:     return "SHIFT";
			case BACKSPACE: return "BACKSPACE";
			case CAPS_LOCK: return "CAPS LOCK";
			case DELETE:    return "DELETE";
			case END:       return "END";
			case ESCAPE:    return "ESCAPE";
			case HOME:      return "HOME";
			case INSERT:    return "INSERT";
			case TAB:       return "TAB";
			case PAGE_DOWN: return "PAGE DOWN";
			case PAGE_UP:   return "PAGE UP";
				
			case NUMPAD_ADD:      return "NUMPAD ADD";
			case NUMPAD_DECIMAL:  return "NUMPAD DECIMAL";
			case NUMPAD_DIVIDE:   return "NUMPAD DIVIDE";
			case NUMPAD_ENTER:    return "NUMPAD ENTER";
			case NUMPAD_MULTIPLY: return "NUMPAD MULTIPLY";
			case NUMPAD_SUBTRACT: return "NUMPAD SUBTRACT";
			
			default:
				return String.fromCharCode(char);
		}
		return String.fromCharCode(char);
	}
	
	private static var keyboardNameMap:Map<String, Int> = {
		var m = new Map<String, Int>();
		m.set("NUMBER_0", Keyboard.NUMBER_0);
		m.set("NUMBER_1", Keyboard.NUMBER_1);
		m.set("NUMBER_2", Keyboard.NUMBER_2);
		m.set("NUMBER_3", Keyboard.NUMBER_3);
		m.set("NUMBER_4", Keyboard.NUMBER_4);
		m.set("NUMBER_5", Keyboard.NUMBER_5);
		m.set("NUMBER_6", Keyboard.NUMBER_6);
		m.set("NUMBER_7", Keyboard.NUMBER_7);
		m.set("NUMBER_8", Keyboard.NUMBER_8);
		m.set("NUMBER_9", Keyboard.NUMBER_9);
		m.set("A", Keyboard.A);
		m.set("B", Keyboard.B);
		m.set("C", Keyboard.C);
		m.set("D", Keyboard.D);
		m.set("E", Keyboard.E);
		m.set("F", Keyboard.F);
		m.set("G", Keyboard.G);
		m.set("H", Keyboard.H);
		m.set("I", Keyboard.I);
		m.set("J", Keyboard.J);
		m.set("K", Keyboard.K);
		m.set("L", Keyboard.L);
		m.set("M", Keyboard.M);
		m.set("N", Keyboard.N);
		m.set("O", Keyboard.O);
		m.set("P", Keyboard.P);
		m.set("Q", Keyboard.Q);
		m.set("R", Keyboard.R);
		m.set("S", Keyboard.S);
		m.set("T", Keyboard.T);
		m.set("U", Keyboard.U);
		m.set("V", Keyboard.V);
		m.set("W", Keyboard.W);
		m.set("X", Keyboard.X);
		m.set("Y", Keyboard.Y);
		m.set("Z", Keyboard.Z);
		m.set("NUMPAD_0", Keyboard.NUMPAD_0);
		m.set("NUMPAD_1", Keyboard.NUMPAD_1);
		m.set("NUMPAD_2", Keyboard.NUMPAD_2);
		m.set("NUMPAD_3", Keyboard.NUMPAD_3);
		m.set("NUMPAD_4", Keyboard.NUMPAD_4);
		m.set("NUMPAD_5", Keyboard.NUMPAD_5);
		m.set("NUMPAD_6", Keyboard.NUMPAD_6);
		m.set("NUMPAD_7", Keyboard.NUMPAD_7);
		m.set("NUMPAD_8", Keyboard.NUMPAD_8);
		m.set("NUMPAD_9", Keyboard.NUMPAD_9);
		m.set("NUMPAD_MULTIPLY", Keyboard.NUMPAD_MULTIPLY);
		m.set("NUMPAD_ADD", Keyboard.NUMPAD_ADD);
		m.set("NUMPAD_ENTER", Keyboard.NUMPAD_ENTER);
		m.set("NUMPAD_SUBTRACT", Keyboard.NUMPAD_SUBTRACT);
		m.set("NUMPAD_DECIMAL", Keyboard.NUMPAD_DECIMAL);
		m.set("NUMPAD_DIVIDE", Keyboard.NUMPAD_DIVIDE);
		m.set("F1", Keyboard.F1);
		m.set("F2", Keyboard.F2);
		m.set("F3", Keyboard.F3);
		m.set("F4", Keyboard.F4);
		m.set("F5", Keyboard.F5);
		m.set("F6", Keyboard.F6);
		m.set("F7", Keyboard.F7);
		m.set("F8", Keyboard.F8);
		m.set("F9", Keyboard.F9);
		m.set("F10", Keyboard.F10);
		m.set("F11", Keyboard.F11);
		m.set("F12", Keyboard.F12);
		m.set("F13", Keyboard.F13);
		m.set("F14", Keyboard.F14);
		m.set("F15", Keyboard.F15);
		m.set("BACKSPACE", Keyboard.BACKSPACE);
		m.set("TAB", Keyboard.TAB);
		m.set("ALTERNATE", Keyboard.ALTERNATE);
		m.set("ENTER", Keyboard.ENTER);
		m.set("COMMAND", Keyboard.COMMAND);
		m.set("SHIFT", Keyboard.SHIFT);
		m.set("CONTROL", Keyboard.CONTROL);
		m.set("BREAK", Keyboard.BREAK);
		m.set("CAPS_LOCK", Keyboard.CAPS_LOCK);
		m.set("NUMPAD", Keyboard.NUMPAD);
		m.set("ESCAPE", Keyboard.ESCAPE);
		m.set("SPACE", Keyboard.SPACE);
		m.set("PAGE_UP", Keyboard.PAGE_UP);
		m.set("PAGE_DOWN", Keyboard.PAGE_DOWN);
		m.set("END", Keyboard.END);
		m.set("HOME", Keyboard.HOME);
		m.set("LEFT", Keyboard.LEFT);
		m.set("RIGHT", Keyboard.RIGHT);
		m.set("UP", Keyboard.UP);
		m.set("DOWN", Keyboard.DOWN);
		m.set("INSERT", Keyboard.INSERT);
		m.set("DELETE", Keyboard.DELETE);
		m.set("NUMLOCK", Keyboard.NUMLOCK);
		m.set("SEMICOLON", Keyboard.SEMICOLON);
		m.set("EQUAL", Keyboard.EQUAL);
		m.set("COMMA", Keyboard.COMMA);
		m.set("MINUS", Keyboard.MINUS);
		m.set("PERIOD", Keyboard.PERIOD);
		m.set("SLASH", Keyboard.SLASH);
		m.set("BACKQUOTE", Keyboard.BACKQUOTE);
		m.set("LEFTBRACKET", Keyboard.LEFTBRACKET);
		m.set("BACKSLASH", Keyboard.BACKSLASH);
		m.set("RIGHTBRACKET", Keyboard.RIGHTBRACKET);
		m.set("QUOTE", Keyboard.QUOTE);
		m;
	}

	public static function keyFromName(k:String):Int
	{
		return keyboardNameMap.get(k);
	}
}
