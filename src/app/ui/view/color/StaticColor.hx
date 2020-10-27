package app.ui.view.color;

class StaticColor implements ColorData {
	final rgba:Array<Float>;

	public function new(r:Float, g:Float, b:Float, a:Float = 1) {
		rgba = [r, g, b, a];
	}

	public function tweakR(newR:Float):StaticColor {
		return new StaticColor(newR, rgba[1], rgba[2], rgba[3]);
	}

	public function tweakG(newG:Float):StaticColor {
		return new StaticColor(rgba[0], newG, rgba[2], rgba[3]);
	}

	public function tweakB(newB:Float):StaticColor {
		return new StaticColor(rgba[0], rgba[1], newB, rgba[3]);
	}

	public function tweakA(newA:Float):StaticColor {
		return new StaticColor(rgba[0], rgba[1], rgba[2], newA);
	}
	
	public function getRGBA():Array<Float> {
		return rgba;
	}

	public static inline function red():StaticColor {
		return new StaticColor(1, 0, 0);
	}

	public static inline function green():StaticColor {
		return new StaticColor(0, 1, 0);
	}

	public static inline function blue():StaticColor {
		return new StaticColor(0, 0, 1);
	}

	public static inline function cyan():StaticColor {
		return new StaticColor(0, 1, 1);
	}

	public static inline function magenta():StaticColor {
		return new StaticColor(1, 0, 1);
	}

	public static inline function yellow():StaticColor {
		return new StaticColor(1, 1, 0);
	}

	public static inline function white():StaticColor {
		return new StaticColor(1, 1, 1);
	}

	public static inline function black():StaticColor {
		return new StaticColor(0, 0, 0);
	}
}
