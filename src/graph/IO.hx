package graph;

enum abstract IO(Bool) {
	var I = false;
	var O = true;

	@:op(!A)
	extern static inline function not(io:IO):IO {
		return !io;
	}
}
