package common;

abstract Maybe<A>(Null<A>) from Null<A> to Null<A> {
	public inline function or(a:A):A {
		return this != null ? this : a;
	}

	public inline function orDo(f:Void->A):A {
		return this != null ? this : f();
	}

	public static inline function of<A>(a:A):Maybe<A> {
		return a;
	}
}
