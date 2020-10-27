package app.ui.view.main.graph;

class ClickSettings {
	public static var DRAG_BEGIN_THRESHOLD_PX:Float = 6;
	public static var TRAIL_INTERVAL_PX:Float = 6;
	public static var PICK_RADIUS_PX:Float = 6;

	public static var LASSO_LEAST_VERTEX_COUNT:Int = 10;
	public static var LASSO_CLOSE_THRESHOLD_RATIO:Float = 0.8;

	public static function setForDesktops():Void {
		DRAG_BEGIN_THRESHOLD_PX = 6;
		TRAIL_INTERVAL_PX = 6;
		PICK_RADIUS_PX = 6;
	}

	public static function setForMobiles():Void {
		DRAG_BEGIN_THRESHOLD_PX = 10;
		TRAIL_INTERVAL_PX = 10;
		PICK_RADIUS_PX = 10;
	}
}
