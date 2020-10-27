package app.ui.core.layout;

enum abstract Axis(Bool) {
	var X = false;
	var Y = true;

	inline function new(value:Bool) {
		this = value;
	}

	public inline function cross():Axis {
		return new Axis(!this);
	}
}
