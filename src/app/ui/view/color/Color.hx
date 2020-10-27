package app.ui.view.color;

import app.ui.view.color.ColorData;

abstract Color(ColorData) from ColorData {
	public var r(get, never):Float;
	public var g(get, never):Float;
	public var b(get, never):Float;
	public var a(get, never):Float;

	inline function get_r():Float {
		return this.getRGBA()[0];
	}

	inline function get_g():Float {
		return this.getRGBA()[1];
	}

	inline function get_b():Float {
		return this.getRGBA()[2];
	}

	inline function get_a():Float {
		return this.getRGBA()[3];
	}

	public function getData():ColorData {
		return this;
	}

	@:from
	static inline function fromArray(rgba:Array<Float>):Color {
		return new StaticColor(rgba[0], rgba[1], rgba[2], rgba.length <= 3 ? 1.0 : rgba[3]);
	}
}
