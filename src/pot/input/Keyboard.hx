package pot.input;
import js.html.CanvasElement;
import js.html.Element;
import js.html.KeyboardEvent;

/**
 * ...
 */
@:allow(pot.input.Input)
abstract Keyboard(KeyboardData) {
	inline function new() {
		this = new KeyboardData();
	}

	@:arrayAccess
	inline function get(code:KeyCode):Key {
		return safeGet(code);
	}

	@:arrayAccess
	inline function getNum(index:Int):Key {
		return safeGet(KeyCode.Digit0 + index);
	}

	@:extern
	inline function safeGet(i:Int):Key {
		if (!this.keys.exists(i)) this.keys.set(i, new Key());
		return this.keys.get(i);
	}

	inline function addEvents(canvas:CanvasElement, elem:Element):Void {
		elem.addEventListener("keydown", (e:KeyboardEvent) -> {
			var code:Int = e.keyCode;
			if (code < KeyboardEvent.DOM_VK_F1 || code > KeyboardEvent.DOM_VK_F24) {
				if (e.cancelable) e.preventDefault();
			}
			if (!this.keys.exists(code)) {
				this.keys.set(code, new Key());
			}
			this.keys.get(code).press();
		});
		elem.addEventListener("keyup", (e:KeyboardEvent) -> {
			var code:Int = e.keyCode;
			if (e.keyCode < KeyboardEvent.DOM_VK_F1 || e.keyCode > KeyboardEvent.DOM_VK_F24) {
				if (e.cancelable) e.preventDefault();
			}
			if (!this.keys.exists(code)) {
				this.keys.set(code, new Key());
			}
			this.keys.get(code).release();
		});
	}

	inline function update():Void {
		var i:Int = 0;
		for (key in this.keys) {
			key.update();
		}
	}

}
