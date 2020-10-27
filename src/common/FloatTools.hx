package common;

class FloatTools {
	extern public static inline function min(a:Float, b:Float):Float {
		return a < b ? a : b;
	}

	extern public static inline function max(a:Float, b:Float):Float {
		return a > b ? a : b;
	}

	extern public static inline function clamp(a:Float, min:Float, max:Float):Float {
		return a < min ? min : a > max ? max : a;
	}

	extern public static inline function abs(a:Float):Float {
		return a < 0 ? -a : a;
	}

	extern public static inline function sign(a:Float):Int {
		return a == 0 ? 0 : a < 0 ? -1 : 1;
	}
}
