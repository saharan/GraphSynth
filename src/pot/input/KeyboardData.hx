package pot.input;

import js.lib.Set;

/**
 * ...
 */
class KeyboardData {
	@:allow(pot.input.Keyboard)
	var keys:Map<CodeValue, Key>;
	@:allow(pot.input.Keyboard)
	var downs:Set<String>;
	@:allow(pot.input.Keyboard)
	var ups:Set<String>;
	@:allow(pot.input.Keyboard)
	var ndowns:Set<String>;
	@:allow(pot.input.Keyboard)
	var nups:Set<String>;

	@:allow(pot.input.Keyboard)
	function new() {
		keys = new Map();
		downs = new Set();
		ups = new Set();
		ndowns = new Set();
		nups = new Set();
	}
}
