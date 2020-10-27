package app.ui.view.color;

import haxe.Timer;

class DynamicColor implements ColorData {
	final rgba:Gen<Array<Float>>;

	public function new(rgba:Gen<Array<Float>>) {
		this.rgba = rgba;
	}

	public function getRGBA():Array<Float> {
		return rgba;
	}

	public static function sine(c1:Color, c2:Color, period:Float):DynamicColor {
		var t1 = Timer.stamp();
		return new DynamicColor(() -> {
			var t2 = Timer.stamp();
			var t = Math.cos((t2 - t1) / period * 2 * Math.PI) * 0.5 + 0.5;
			var rgba1 = c1.getData().getRGBA();
			var rgba2 = c2.getData().getRGBA();
			var r1 = rgba1[0];
			var g1 = rgba1[1];
			var b1 = rgba1[2];
			var a1 = rgba1[3];
			var r2 = rgba2[0];
			var g2 = rgba2[1];
			var b2 = rgba2[2];
			var a2 = rgba2[3];
			return [r1 + t * (r2 - r1), g1 + t * (g2 - g1), b1 + t * (b2 - b1), a1 + t * (a2 - a1)];
		});
	}

	public static function fade(c:Color, from:Float, duration:Float):DynamicColor {
		var t1 = Timer.stamp();
		return new DynamicColor(() -> {
			var t2 = Timer.stamp();
			var t = (t2 - t1 - from) / duration;
			var alpha = t < 0 ? 1 : t > 1 ? 0 : 1 - t;
			var rgba = c.getData().getRGBA();
			return [rgba[0], rgba[1], rgba[2], rgba[3] * alpha];
		});
	}
}
