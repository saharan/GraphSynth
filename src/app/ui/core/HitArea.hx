package app.ui.core;

@:using(app.ui.core.HitArea.HitAreaTools)
enum HitArea {
	Transparent;
	Box;
	Custom(hitTest:(w:Float, h:Float, x:Float, y:Float) -> Bool);
}

class HitAreaTools {
	public static inline function test(area:HitArea, w:Float, h:Float, x:Float, y:Float):Bool {
		return switch area {
			case Transparent:
				false;
			case Box:
				x >= 0 && y >= 0 && x < w && y < h;
			case Custom(hitTest):
				hitTest(w, h, x, y);
		}
	}
}
