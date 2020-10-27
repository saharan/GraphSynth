package app.ui.core;

import app.ui.core.layout.Axis;

class Padding extends Border<Length> {
	public function new(left:Length, top:Length, right:Length, bottom:Length) {
		super(left, top, right, bottom);
	}

	public inline function calcAlong(axis:Axis, parentSize:Float):Float {
		return switch axis {
			case X:
				left.calc(parentSize) + right.calc(parentSize);
			case Y:
				top.calc(parentSize) + bottom.calc(parentSize);
		}
	}
}
