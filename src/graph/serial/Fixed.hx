package graph.serial;

abstract Fixed(Int) {
	inline function new(val:Int) {
		this = val;
	}

	@:from
	static inline function fromFloat(v:Float):Fixed {
		v = v < -10000 ? -10000 : v > 10000 ? 10000 : v;
		var vi = Math.round(v * 10000);
		if (vi == 0 && v != 0)
			vi = v > 0 ? 1 : -1;
		return new Fixed(vi);
	}

	@:to
	public extern inline function toFloat():Float {
		return this / 10000;
	}

	@:op(A + B)
	static inline function add(a:Fixed, b:Fixed):Fixed {
		return a.toFloat() + b.toFloat();
	}

	@:op(A - B)
	static inline function sub(a:Fixed, b:Fixed):Fixed {
		return a.toFloat() - b.toFloat();
	}

	@:op(A * B)
	static inline function mult(a:Fixed, b:Fixed):Fixed {
		return a.toFloat() * b.toFloat();
	}

	@:op(-A)
	static inline function neg(a:Fixed):Fixed {
		return -a.toFloat();
	}
}
