package phys;

class Point {
	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;
	public var invM:Float;
	public var damp:Float;

	public function new(x:Float, y:Float, invM:Float = 1.0) {
		this.x = x;
		this.y = y;
		this.invM = invM;
		vx = 0;
		vy = 0;
		damp = 0.98;
	}

	public function move():Void {
		x += vx;
		y += vy;
		vx *= damp;
		vy *= damp;
	}
}
