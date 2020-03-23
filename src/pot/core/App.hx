package pot.core;

import js.html.CanvasElement;
import pot.input.Input;

/**
 * Main application class
 */
@:allow(pot.core)
class App {
	/**
	 * Pot instance
	 */
	var pot:Pot;

	/**
	 * User input
	 */
	var input:Input;

	/**
	 * The canvas element
	 */
	var canvas:CanvasElement;

	/**
	 * The number of `App.frame()` calls. Count starts from `0`.
	 */
	var frameCount:Int;

	public function new(canvas:CanvasElement, captureInput:Bool = true) {
		this.canvas = canvas;
		pot = new Pot(this, canvas);
		if (captureInput) {
			input = new Input(canvas, pot);
		} else {
			input = null;
		}
		frameCount = 0;
		setup();
	}

	/**
	 * Called on initialization
	 */
	function setup():Void {}

	/**
	 * Called every frame
	 */
	function loop():Void {}
}
