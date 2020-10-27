package pot.core;

import js.Browser;
import js.html.CanvasElement;
import pot.util.Timer;

/**
 * Pot Engine
 */
class Pot {
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var pixelRatio(default, null):Float;

	var app:App;
	var canvas:CanvasElement;
	var timer:Timer;

	@:allow(pot.input)
	public function new(app:App, canvas:CanvasElement) {
		this.app = app;
		this.canvas = canvas;
		timer = new Timer(frame);
	}

	public function resize(width:Int, height:Int, pixelRatio:Float = 1):Void {
		this.width = width;
		this.height = height;
		this.pixelRatio = pixelRatio;
		canvas.width = width;
		canvas.height = height;
	}

	public function frameRate(fps:Float):Void {
		if (fps == 0) {
			timer.setFrameRate(60);
			timer.setUseAnimationFrame(true);
		} else {
			timer.setFrameRate(fps);
		}
	}

	public function start():Void {
		timer.start();
	}

	public function stop():Void {
		timer.stop();
	}

	function frame():Void {
		if (app.input != null)
			app.input.update();
		app.loop();
		app.frameCount++;
	}
}
