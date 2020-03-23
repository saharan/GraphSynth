package phys;

class Spring {
	public var p1:Point;
	public var p2:Point;
	public var length:Float;
	public var stiff:Bool;

	public var prevDist(default, null):Float;

	var totalImp:Float;

	public function new(p1:Point, p2:Point, length:Float, stiff:Bool) {
		this.p1 = p1;
		this.p2 = p2;
		prevDist = dist(p1, p2);
		this.length = length;
		this.stiff = stiff;
		totalImp = 0;
	}

	public function preSolve():Void {
		prevDist = dist(p1, p2);
		totalImp *= 0.5;
		var x1:Float = p1.x + p1.vx;
		var y1:Float = p1.y + p1.vy;
		var x2:Float = p2.x + p2.vx;
		var y2:Float = p2.y + p2.vy;
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		var invDist:Float = dist > 0 ? 1 / dist : 0;
		var nx:Float = dx * invDist;
		var ny:Float = dy * invDist;
		p1.vx += nx * totalImp * p1.invM;
		p1.vy += ny * totalImp * p1.invM;
		p2.vx -= nx * totalImp * p2.invM;
		p2.vy -= ny * totalImp * p2.invM;
	}

	public function solve():Void {
		var x1:Float = p1.x + p1.vx;
		var y1:Float = p1.y + p1.vy;
		var x2:Float = p2.x + p2.vx;
		var y2:Float = p2.y + p2.vy;
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		var invDist:Float = dist > 0 ? 1 / dist : 0;
		var nx:Float = dx * invDist;
		var ny:Float = dy * invDist;
		var cfm:Float = stiff ? 0 : 10.0;
		var denom:Float = 1 / ((p1.invM + p2.invM) * (1.0 + cfm));
		var baum:Float = 0.7;
		var diff:Float = length - dist;
		var imp:Float = denom * diff * baum;
		totalImp += imp;
		p1.vx += nx * imp * p1.invM;
		p1.vy += ny * imp * p1.invM;
		p2.vx -= nx * imp * p2.invM;
		p2.vy -= ny * imp * p2.invM;
	}

	public function postSolve():Void {}

	extern inline function dist(a:Point, b:Point):Float {
		var dx:Float = a.x - b.x;
		var dy:Float = a.y - b.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
}
