package com.stencyl.utils.motion;

import com.stencyl.utils.motion.Easing.*;

/*
 * All algorithms copied from 'tweenxcore.Tools.Easing'.
 */

class Easing
{
	public static var linear = new Linear();
	public static var sineIn = new SineIn();
	public static var sineOut = new SineOut();
	public static var sineInOut = new SineInOut();
	public static var sineOutIn = new SineOutIn();
	public static var quadIn = new QuadIn();
	public static var quadOut = new QuadOut();
	public static var quadInOut = new QuadInOut();
	public static var quadOutIn = new QuadOutIn();
	public static var cubicIn = new CubicIn();
	public static var cubicOut = new CubicOut();
	public static var cubicInOut = new CubicInOut();
	public static var cubicOutIn = new CubicOutIn();
	public static var quartIn = new QuartIn();
	public static var quartOut = new QuartOut();
	public static var quartInOut = new QuartInOut();
	public static var quartOutIn = new QuartOutIn();
	public static var quintIn = new QuintIn();
	public static var quintOut = new QuintOut();
	public static var quintInOut = new QuintInOut();
	public static var quintOutIn = new QuintOutIn();
	public static var expoIn = new ExpoIn();
	public static var expoOut = new ExpoOut();
	public static var expoInOut = new ExpoInOut();
	public static var expoOutIn = new ExpoOutIn();
	public static var circIn = new CircIn();
	public static var circOut = new CircOut();
	public static var circInOut = new CircInOut();
	public static var circOutIn = new CircOutIn();
	public static var bounceIn = new BounceIn();
	public static var bounceOut = new BounceOut();
	public static var bounceInOut = new BounceInOut();
	public static var bounceOutIn = new BounceOutIn();
	public static var backIn = new BackIn();
	public static var backOut = new BackOut();
	public static var backInOut = new BackInOut();
	public static var backOutIn = new BackOutIn();
	public static var elasticIn = new ElasticIn();
	public static var elasticOut = new ElasticOut();
	public static var elasticInOut = new ElasticInOut();
	public static var elasticOutIn = new ElasticOutIn();
	public static var warpOut = new WarpOut();
	public static var warpIn = new WarpIn();
	public static var warpInOut = new WarpInOut();
	public static var warpOutIn = new WarpOutIn();
	
	static inline var PI       = 3.1415926535897932384626433832795;
    static inline var PI_H     = PI / 2;
    static inline var LN_2     = 0.6931471805599453;
    static inline var LN_2_10  = 6.931471805599453;
	static inline var overshoot:Float = 1.70158;
	static inline var amplitude:Float = 1;
	static inline var period:Float = 0.0003;

	public function new(){}

	public function apply(t:Float):Float
	{
		return 0;
	}
}

class Linear extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
		return t;
	}
}

class SineIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
		return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            1 - Math.cos(t * PI_H);
        }
	}
}

class SineOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            Math.sin(t * PI_H);
        }
    }
}

class SineInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            -0.5 * (Math.cos(PI * t) - 1);
        }
    }
}

class SineOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return  if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else if (t < 0.5) {
            0.5 * Math.sin((t * 2) * PI_H);
        } else {
            -0.5 * Math.cos((t * 2 - 1) * PI_H) + 1;
        }
    }
}

class QuadIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * t;
    }
}

class QuadOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return -t * (t - 2);
    }
}

class QuadInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? 2 * t * t : -2 * ((t -= 1) * t) + 1;
    }
}

class QuadOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? -0.5 * (t = (t * 2)) * (t - 2) : 0.5 * (t = (t * 2 - 1)) * t + 0.5;
    }
}

class CubicIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * t * t;
    }
}

class CubicOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t = t - 1) * t * t + 1;
    }
}

class CubicInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ?
            0.5 * t * t * t :
            0.5 * ((t -= 2) * t * t + 2);
    }
}

class CubicOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 0.5 * ((t = t * 2 - 1) * t * t + 1);
    }
}

class QuartIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t *= t) * t;
    }
}

class QuartOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 1 - (t = (t = t - 1) * t) * t;
    }
}

class QuartInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ? 0.5 * (t *= t) * t : -0.5 * ((t = (t -= 2) * t) * t - 2);
    }
}

class QuartOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? -0.5 * (t = (t = t * 2 - 1) * t) * t + 0.5 : 0.5 * (t = (t = t * 2 - 1) * t) * t + 0.5;
    }
}

class QuintIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * (t *= t) * t;
    }
}

class QuintOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t = t - 1) * (t *= t) * t + 1;
    }
}

class QuintInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ? 0.5 * t * (t *= t) * t : 0.5 * (t -= 2) * (t *= t) * t + 1;
    }
}

class QuintOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 0.5 * ((t = t * 2 - 1) * (t *= t) * t + 1);
    }
}

class ExpoIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t == 0 ? 0 : Math.exp(LN_2_10 * (t - 1));
    }
}

class ExpoOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t == 1 ? 1 : (1 - Math.exp(-LN_2_10 * t));
    }
}

class ExpoInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else if ((t *= 2) < 1) {
            0.5 * Math.exp(LN_2_10 * (t - 1));
        } else {
            0.5 * (2 - Math.exp(-LN_2_10 * (t - 1)));
        }
    }
}

class ExpoOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0.5) {
            0.5 * (1 - Math.exp(-20 * LN_2 * t));
        } else if (t == 0.5) {
            0.5;
        } else {
            0.5 * (Math.exp(20 * LN_2 * (t - 1)) + 1);
        }
    }
}

class CircIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < -1 || 1 < t) 0 else 1 - Math.sqrt(1 - t * t);
    }
}

class CircOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0 || 2 < t) 0 else Math.sqrt(t * (2 - t));
    }
}

class CircInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < -0.5 || 1.5 < t) 0.5 else if ((t *= 2) < 1)- 0.5 * (Math.sqrt(1 - t * t) - 1) else 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
    }
}

class CircOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0) 0 else if (1 < t) 1 else if (t < 0.5) 0.5 * Math.sqrt(1 - (t = t * 2 - 1) * t) else -0.5 * ((Math.sqrt(1 - (t = t * 2 - 1) * t) - 1) - 1);
    }
}

class BounceIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if ((t = 1 - t) < (1 / 2.75)) {
            1 - ((7.5625 * t * t));
        } else if (t < (2 / 2.75)) {
            1 - ((7.5625 * (t -= (1.5 / 2.75)) * t + 0.75));
        } else if (t < (2.5 / 2.75)) {
            1 - ((7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375));
        } else {
            1 - ((7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375));
        }
    }
}

class BounceOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < (1 / 2.75)) {
            (7.5625 * t * t);
        } else if (t < (2 / 2.75)) {
            (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75);
        } else if (t < (2.5 / 2.75)) {
            (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375);
        } else {
            (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375);
        }
    }
}

class BounceInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0.5) {
            if ((t = (1 - t * 2)) < (1 / 2.75)) {
                (1 - ((7.5625 * t * t))) * 0.5;
            } else if (t < (2 / 2.75)) {
                (1 - ((7.5625 * (t -= (1.5 / 2.75)) * t + 0.75))) * 0.5;
            } else if (t < (2.5 / 2.75)) {
                (1 - ((7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375))) * 0.5;
            } else {
                (1 - ((7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375))) * 0.5;
            }
        } else {
            if ((t = (t * 2 - 1)) < (1 / 2.75)) {
                ((7.5625 * t * t)) * 0.5 + 0.5;
            } else if (t < (2 / 2.75))    {
                ((7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)) * 0.5 + 0.5;
            } else if (t < (2.5 / 2.75))    {
                ((7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)) * 0.5 + 0.5;
            } else {
                ((7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)) * 0.5 + 0.5;
            }
        }
    }
}

class BounceOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0.5) {
            if ((t = (t * 2)) < (1 / 2.75)) {
                0.5 * (7.5625 * t * t);
            } else if (t < (2 / 2.75)) {
                0.5 * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75);
            } else if (t < (2.5 / 2.75)) {
                0.5 * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375);
            } else {
                0.5 * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375);
            }
        } else {
            if ((t = (1 - (t * 2 - 1))) < (1 / 2.75)) {
                0.5 - (0.5 * (7.5625 * t * t)) + 0.5;
            } else if (t < (2 / 2.75)) {
                0.5 - (0.5 * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)) + 0.5;
            } else if (t < (2.5 / 2.75)) {
                0.5 - (0.5 * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)) + 0.5;
            } else {
                0.5 - (0.5 * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)) + 0.5;
            }
        }
    }
}
	
class BackIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            t * t * ((overshoot + 1) * t - overshoot);
        }
    }
}

class BackOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            ((t = t - 1) * t * ((overshoot + 1) * t + overshoot) + 1);
        }
    }
}

class BackInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else if ((t *= 2) < 1) {
            0.5 * (t * t * (((overshoot * 1.525) + 1) * t - overshoot * 1.525));
        } else {
            0.5 * ((t -= 2) * t * (((overshoot * 1.525) + 1) * t + overshoot * 1.525) + 2);
        }
    }
}

class BackOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else if (t < 0.5) {
            0.5 * ((t = t * 2 - 1) * t * ((overshoot + 1) * t + overshoot) + 1);
        } else {
            0.5 * (t = t * 2 - 1) * t * ((overshoot + 1) * t - overshoot) + 0.5;
        }
    }
}

class ElasticIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            var s:Float = period / 4;
            -(amplitude * Math.exp(LN_2_10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * PI) / period));
        }
    }
}

class ElasticOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            var s:Float = period / 4;
            Math.exp(-LN_2_10 * t) * Math.sin((t * 0.001 - s) * (2 * PI) / period) + 1;
        }
    }
}

class ElasticInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t == 0) {
            0;
        } else if (t == 1) {
            1;
        } else {
            var s:Float = period / 4;

            if ((t *= 2) < 1) {
                -0.5 * (amplitude * Math.exp(LN_2_10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * PI) / period));
            } else {
                amplitude * Math.exp(-LN_2_10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * PI) / period) * 0.5 + 1;
            }
        }
    }
}

class ElasticOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0.5) {
            if ((t *= 2) == 0) {
                0;
            } else {
                var s = period / 4;
                (amplitude / 2) * Math.exp(-LN_2_10 * t) * Math.sin((t * 0.001 - s) * (2 * PI) / period) + 0.5;
            }
        } else {
            if (t == 0.5) {
                0.5;
            } else if (t == 1) {
                1;
            } else {
                t = t * 2 - 1;
                var s = period / 4;
                -((amplitude / 2) * Math.exp(LN_2_10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * PI) / period)) + 0.5;
            }
        }
    }
}

class WarpOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t <= 0 ? 0 : 1;
    }
}

class WarpIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t < 1 ? 0 : 1;
    }
}

class WarpInOut extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t < 0.5 ? 0 : 1;
    }
}

class WarpOutIn extends Easing
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t <= 0) 0 else if (t < 1) 0.5 else 1;
    }
}