package graph.serial;

abstract Fixed(Int) {
	inline function new(val:Int) {
		this = val;
	}

	@:from
	static inline function fromFloat(v:Float):Fixed {
		return new Fixed(Math.round(v * 10000));
	}

	@:to
	inline function toFloat():Float {
		return this / 10000;
	}
}
