package pot.input;
import js.html.CanvasElement;
import js.html.Element;
import js.html.KeyboardEvent;

/**
 * ...
 */
@:allow(pot.input.Keyboard)
class Key {
	public var down(default, null):Bool;
	public var pdown(default, null):Bool;
	public var ddown(default, null):Int;
	var ndown:Bool;
	var ndown2:Bool;

	public function new() {
		down = false;
		pdown = false;
		ndown = false;
		ndown2 = false;
		ddown = 0;
	}

	function press():Void {
		ndown = true;
		ndown2 = true;
	}

	function release():Void {
		ndown = false;
	}

	function update():Void {
		pdown = down;
		down = ndown || ndown2;
		ndown2 = false;
		ddown = (down ? 1 : 0) - (pdown ? 1 : 0);
	}

}
