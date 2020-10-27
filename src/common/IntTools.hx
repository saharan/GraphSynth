package common;

class IntTools {
	extern public static inline function min(a:Int, b:Int):Int {
		return a < b ? a : b;
	}

	extern public static inline function max(a:Int, b:Int):Int {
		return a > b ? a : b;
	}

	extern public static inline function clamp(a:Int, min:Int, max:Int):Int {
		return a < min ? min : a > max ? max : a;
	}

	extern public static inline function abs(a:Int):Int {
		return a < 0 ? -a : a;
	}

	extern public static inline function sign(a:Int):Int {
		return a == 0 ? 0 : a < 0 ? -1 : 1;
	}
}
