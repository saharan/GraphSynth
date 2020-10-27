package app.ui.core;

import app.ui.core.layout.Axis;

class Border<S> {
	public var left:S;
	public var top:S;
	public var right:S;
	public var bottom:S;

	public function new(left:S, top:S, right:S, bottom:S) {
		set(left, top, right, bottom);
	}

	public inline function set(left:S, top:S, right:S, bottom:S):Void {
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}

	public inline function setAlong(axis:Axis, start:S, end:S):Void {
		switch axis {
			case X:
				left = start;
				right = end;
			case Y:
				top = start;
				bottom = end;
		}
	}

	public inline function all(S:S):Void {
		set(S, S, S, S);
	}

	public inline function start(axis:Axis):S {
		return switch axis {
			case X:
				left;
			case Y:
				top;
		}
	}

	public inline function end(axis:Axis):S {
		return switch axis {
			case X:
				right;
			case Y:
				bottom;
		}
	}
}
