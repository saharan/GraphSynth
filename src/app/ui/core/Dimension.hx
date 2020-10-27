package app.ui.core;

import app.ui.core.layout.Axis;

class Dimension {
	public var w:LengthOrAuto;
	public var h:LengthOrAuto;

	public function new(w:LengthOrAuto, h:LengthOrAuto) {
		set(w, h);
	}

	public inline function set(w:LengthOrAuto, h:LengthOrAuto):Void {
		this.w = w;
		this.h = h;
	}

	public inline function along(axis:Axis):LengthOrAuto {
		return switch axis {
			case X:
				w;
			case Y:
				h;
		}
	}
}
