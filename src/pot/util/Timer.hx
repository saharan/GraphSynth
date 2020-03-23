package pot.util;
import js.Browser;

/**
 * An accurate timer
 */
class Timer {
	static inline var MIN_SLEEP_TIME:Int = 5;
	var frame:Void -> Void;
	var targetSleep:Float;
	var nextTime:Float;
	var running:Bool;
	var useAnimationFrame:Bool;

	public function new(frame:Void -> Void) {
		this.frame = frame;
		targetSleep = 1000 / 60;
		useAnimationFrame = false;
	}

	public function start():Void {
		if (running) return;
		nextTime = now();
		running = true;
		Browser.window.setTimeout(loop, 0);
	}

	public function stop():Void {
		if (!running) return;
		running = false;
	}

	public function setFrameRate(frameRate:Float):Void {
		targetSleep = 1000 / frameRate;
	}
	
	public function setUseAnimationFrame(useAnimationFrame:Bool) {
		this.useAnimationFrame = useAnimationFrame;
	}

	function loop(?arg:Float):Void {
		if (!running) return;
		frame();
		
		var currentTime:Float = now();
		nextTime += targetSleep;
		if (nextTime < currentTime + MIN_SLEEP_TIME) {
			nextTime = currentTime + MIN_SLEEP_TIME;
		}
		var sleep:Int = Std.int(nextTime - currentTime + 0.5);
		
		if (useAnimationFrame) {
			Browser.window.requestAnimationFrame(loop);
		} else {
			Browser.window.setTimeout(loop, sleep);
		}
	}

	inline function now():Float {
		return untyped __js__("Date.now()");
	}

}
