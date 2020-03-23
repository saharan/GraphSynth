package app;

import js.Browser;

class UISetting {
	public static final pixelRatio:Int = Std.int(Browser.window.devicePixelRatio);
	public static final dragBeginThreshold:Float = pixelRatio * 10;
	public static final tapErrorThreshold:Float = pixelRatio * 20;
	public static final longPressTimeThreshold:Int = 20;
}