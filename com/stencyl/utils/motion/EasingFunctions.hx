package com.stencyl.utils.motion;

/*
 * All algorithms copied from 'tweenxcore.Tools.Easing'.
 */

import com.stencyl.utils.motion.EasingConstants.*;

class Linear extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
		return t;
	}
}

class SineIn extends EasingFunction
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

class SineOut extends EasingFunction
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

class SineInOut extends EasingFunction
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

class SineOutIn extends EasingFunction
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

class QuadIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * t;
    }
}

class QuadOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return -t * (t - 2);
    }
}

class QuadInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? 2 * t * t : -2 * ((t -= 1) * t) + 1;
    }
}

class QuadOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? -0.5 * (t = (t * 2)) * (t - 2) : 0.5 * (t = (t * 2 - 1)) * t + 0.5;
    }
}

class CubicIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * t * t;
    }
}

class CubicOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t = t - 1) * t * t + 1;
    }
}

class CubicInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ?
            0.5 * t * t * t :
            0.5 * ((t -= 2) * t * t + 2);
    }
}

class CubicOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 0.5 * ((t = t * 2 - 1) * t * t + 1);
    }
}

class QuartIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t *= t) * t;
    }
}

class QuartOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 1 - (t = (t = t - 1) * t) * t;
    }
}

class QuartInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ? 0.5 * (t *= t) * t : -0.5 * ((t = (t -= 2) * t) * t - 2);
    }
}

class QuartOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t < 0.5) ? -0.5 * (t = (t = t * 2 - 1) * t) * t + 0.5 : 0.5 * (t = (t = t * 2 - 1) * t) * t + 0.5;
    }
}

class QuintIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t * (t *= t) * t;
    }
}

class QuintOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return (t = t - 1) * (t *= t) * t + 1;
    }
}

class QuintInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return ((t *= 2) < 1) ? 0.5 * t * (t *= t) * t : 0.5 * (t -= 2) * (t *= t) * t + 1;
    }
}

class QuintOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return 0.5 * ((t = t * 2 - 1) * (t *= t) * t + 1);
    }
}

class ExpoIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t == 0 ? 0 : Math.exp(LN_2_10 * (t - 1));
    }
}

class ExpoOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t == 1 ? 1 : (1 - Math.exp(-LN_2_10 * t));
    }
}

class ExpoInOut extends EasingFunction
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

class ExpoOutIn extends EasingFunction
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

class CircIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < -1 || 1 < t) 0 else 1 - Math.sqrt(1 - t * t);
    }
}

class CircOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0 || 2 < t) 0 else Math.sqrt(t * (2 - t));
    }
}

class CircInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < -0.5 || 1.5 < t) 0.5 else if ((t *= 2) < 1)- 0.5 * (Math.sqrt(1 - t * t) - 1) else 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
    }
}

class CircOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t < 0) 0 else if (1 < t) 1 else if (t < 0.5) 0.5 * Math.sqrt(1 - (t = t * 2 - 1) * t) else -0.5 * ((Math.sqrt(1 - (t = t * 2 - 1) * t) - 1) - 1);
    }
}

class BounceIn extends EasingFunction
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

class BounceOut extends EasingFunction
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

class BounceInOut extends EasingFunction
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

class BounceOutIn extends EasingFunction
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
	
class BackIn extends EasingFunction
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

class BackOut extends EasingFunction
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

class BackInOut extends EasingFunction
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

class BackOutIn extends EasingFunction
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

class ElasticIn extends EasingFunction
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

class ElasticOut extends EasingFunction
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

class ElasticInOut extends EasingFunction
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

class ElasticOutIn extends EasingFunction
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

class WarpOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t <= 0 ? 0 : 1;
    }
}

class WarpIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t < 1 ? 0 : 1;
    }
}

class WarpInOut extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return t < 0.5 ? 0 : 1;
    }
}

class WarpOutIn extends EasingFunction
{
	public function new(){super();}
	override public function apply(t:Float):Float {
        return if (t <= 0) 0 else if (t < 1) 0.5 else 1;
    }
}