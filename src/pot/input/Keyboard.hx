package pot.input;

import js.html.FocusEvent;
import js.Browser;
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
	inline function get(code:CodeValue):Key {
		return safeGet(code);
	}

	@:arrayAccess
	inline function getNum(index:Int):Key {
		return safeGet(CodeValue.DIGITS[index]);
	}

	@:extern
	inline function safeGet(code:CodeValue):Key {
		if (!this.keys.exists(code))
			this.keys[code] = new Key();
		return this.keys[code];
	}

	inline function addEvents(canvas:CanvasElement, elem:Element):Void {
		elem.addEventListener("keydown", (e:KeyboardEvent) -> {
			var code:CodeValue = CodeValue.fromString(e.code);
			if (code == null)
				return;
			if (!CodeValue.FUNCTIONS.contains(code) && e.cancelable) {
				e.preventDefault();
			}
			safeGet(code).press();
			this.ndowns.add(e.key);
		});
		elem.addEventListener("keyup", (e:KeyboardEvent) -> {
			var code:CodeValue = CodeValue.fromString(e.code);
			if (code == null)
				return;
			if (!CodeValue.FUNCTIONS.contains(code) && e.cancelable) {
				e.preventDefault();
			}
			safeGet(code).release();
			this.nups.add(e.key);
		});
		Browser.window.addEventListener("blur", (e:FocusEvent) -> {
			for (key in this.keys) {
				key.release();
			}
		});
	}

	inline function update():Void {
		for (key in this.keys) {
			key.update();
		}
		this.downs.clear();
		this.ups.clear();
		for (down in this.ndowns) {
			this.downs.add(down);
		}
		for (up in this.ups) {
			this.ups.add(up);
		}
		this.ndowns.clear();
		this.nups.clear();
	}

	public function isControlDown():Bool {
		return safeGet(ControlLeft).down || safeGet(ControlRight).down;
	}

	public function isShiftDown():Bool {
		return safeGet(ShiftLeft).down || safeGet(ShiftRight).down;
	}

	public function isAltDown():Bool {
		return safeGet(AltLeft).down || safeGet(AltRight).down;
	}

	public function isKeyDown(key:String):Bool {
		return this.downs.has(key);
	}

	public function isKeyUp(key:String):Bool {
		return this.ups.has(key);
	}

	public function forEachDownKey(f:String->Void):Void {
		for (key in this.downs) {
			f(key);
		}
	}

	public function forEachUpKey(f:String->Void):Void {
		for (key in this.ups) {
			f(key);
		}
	}

	public function forEachCode(f:CodeValue->Key->Void):Void {
		for (code => key in this.keys) {
			f(code, key);
		}
	}
}
