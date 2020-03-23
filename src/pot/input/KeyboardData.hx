package pot.input;

/**
 * ...
 */
class KeyboardData {
	@:allow(pot.input.Keyboard)
	var keys:Map<Int, Key>;

	@:allow(pot.input.Keyboard)
	function new() {
		keys = new Map();
	}
}
