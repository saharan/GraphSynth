package common;

@:forward(a, b)
abstract Pair<A, B>(PairData<A, B>) {
	inline function new(a:A, b:B) {
		this = new PairData<A, B>(a, b);
	}

	public static inline function of<A, B>(a:A, b:B):Pair<A, B> {
		return new Pair(a, b);
	}
}

class PairData<A, B> {
	public var a:A;
	public var b:B;

	public inline function new(a:A, b:B) {
		this.a = a;
		this.b = b;
	}
}
