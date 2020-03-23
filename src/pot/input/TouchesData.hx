package pot.input;

/**
 * ...
 */
class TouchesData {
	@:allow(pot.input.Touches)
	var touches:Array<Touch>;

	@:allow(pot.input.Touches)
	function new() {
		touches = [];
	}

	@:allow(pot.input.Touches)
	function getByRawId(rawId:Int, create:Bool = false):Touch {
		for (t in touches) {
			if (t.rawId == rawId) {
				return t;
			}
		}
		return create ? newTouch(rawId) : null;
	}

	function newTouch(rawId:Int):Touch {
		var minId:Int = 0;
		while (true) {
			var tmp:Int = minId;
			for (t in touches) {
				if (t.id == minId) minId++;
			}
			if (tmp == minId) break;
		}
		var touch:Touch = new Touch();
		touch.rawId = rawId;
		touch.id = minId;
		touches.push(touch);
		return touch;
	}
}
