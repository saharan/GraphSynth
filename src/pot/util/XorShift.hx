package pot.util;

/**
 * ...
 */
class XorShift {
	var x:Int = 0;

	public function new(seed:Int = 0) {
		if (seed == 0) {
			x = Std.random(2147483647) + 1;
		} else {
			x = seed;
		}
	}

	public inline function nextInt():Int {
		x = x ^ (x << 13);
		x = x ^ (x >>> 17);
		return x = x ^ (x << 15);
	}

	public inline function next():Float {
		return (nextInt() & 0x7fffffff) / 2147483648.0;
	}

	public inline function nextUniform(a:Float, b:Float):Float {
		return a + next() * (b - a);
	}

	public function setSeed(seed:Int = 0):Void {
		if (seed == 0) {
			x = Std.random(2147483647) + 1;
		} else {
			x = seed;
		}
	}
}
