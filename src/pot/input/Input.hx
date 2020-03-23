package pot.input;
import js.Browser;
import js.html.CanvasElement;
import js.html.Element;
import pot.core.Pot;

/**
 * ...
 */
class Input {
	public var mouse(default, null):Mouse;
	public var touches(default, null):Touches;
	public var keyboard(default, null):Keyboard;
	
	public var scalingMode:InputScalingMode;

	@:allow(pot.core.App)
	function new(canvas:CanvasElement, pot:Pot) {
		mouse = new Mouse();
		touches = new Touches();
		keyboard = new Keyboard();
		scalingMode = Canvas;
		addEvents(canvas, pot);
	}

	function addEvents(canvas:CanvasElement, pot:Pot):Void {
		mouse.addEvents(canvas, canvas, this, pot);
		touches.addEvents(canvas, canvas, this, pot);
		keyboard.addEvents(canvas, Browser.document.body);
	}

	@:allow(pot.core.Pot)
	function update():Void {
		mouse.update();
		touches.update();
		keyboard.update();
	}

}
