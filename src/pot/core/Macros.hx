package pot.core;

/**
 * ...
 */
extern class Macros {
	macro public static function min(a, b) {
		return macro {
			var a = $a;
			var b = $b;
			return a < b ? a : b;
		};
	}

	macro public static function max(a, b) {
		return macro {
			var a = $a;
			var b = $b;
			return a > b ? a : b;
		};
	}

	macro public static function clamp(a, min, max) {
		return macro {
			var a = $a;
			var min = $min;
			var max = $max;
			return a < min ? min : a > max ? max : a;
		};
	}
}
