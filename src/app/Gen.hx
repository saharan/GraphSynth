package app;

@:callable
abstract Gen<T>(Void->T) from Void->T {
	inline function new(f:Void->T) {
		this = f;
	}

	@:from
	extern static inline function fromT<T>(t:T):Gen<T> {
		return new Gen<T>(() -> t);
	}

	@:to
	extern inline function toT<T>():T {
		return this();
	}
}
