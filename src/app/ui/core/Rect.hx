package app.ui.core;

import app.ui.core.layout.Axis;

class Rect implements AnchorPeek implements SizePeek {
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public function new(x:Float, y:Float, w:Float, h:Float) {
		set(x, y, w, h);
	}

	public inline function set(x:Float, y:Float, w:Float, h:Float):Void {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public inline function start(axis:Axis):Float {
		return switch axis {
			case X:
				x;
			case Y:
				y;
		}
	}

	public inline function end(axis:Axis):Float {
		return switch axis {
			case X:
				x + w;
			case Y:
				y + h;
		}
	}

	public inline function size(axis:Axis):Float {
		return switch axis {
			case X:
				w;
			case Y:
				h;
		}
	}

	public inline function setAlong(axis:Axis, start:Float, size:Float):Void {
		switch axis {
			case X:
				x = start;
				w = size;
			case Y:
				y = start;
				h = size;
		}
	}

	public inline function getX():Float {
		return x;
	}

	public inline function getY():Float {
		return y;
	}

	public inline function getW():Float {
		return w;
	}

	public inline function getH():Float {
		return h;
	}

	public function hitTest(x:Float, y:Float):Bool {
		return x >= this.x && y >= this.y && x < this.x + w && y < this.y + h;
	}
}
