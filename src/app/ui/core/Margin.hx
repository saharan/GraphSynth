package app.ui.core;

import app.ui.core.layout.Axis;

class Margin extends Border<LengthOrAuto> {
	public function new(left:LengthOrAuto, top:LengthOrAuto, right:LengthOrAuto, bottom:LengthOrAuto) {
		super(left, top, right, bottom);
	}

	public inline function calcAssigningZeroToAutoAlong(axis:Axis, parentSize:Float):Float {
		return switch axis {
			case X:
				left.toLength(Zero).calc(parentSize) + right.toLength(Zero).calc(parentSize);
			case Y:
				top.toLength(Zero).calc(parentSize) + bottom.toLength(Zero).calc(parentSize);
		}
	}
}
