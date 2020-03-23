package phys;

class World {
	var ps:Array<Point>;
	var ss:Array<Spring>;

	public function new() {
		ps = [];
		ss = [];
	}
	
	public function addPoint(p:Point):Void {
		ps.push(p);
	}
	
	public function removePoint(p:Point):Bool {
		return ps.remove(p);
	}
	
	public function addSpring(s:Spring):Void {
		ss.push(s);
	}
	
	public function removeSpring(s:Spring):Bool {
		return ss.remove(s);
	}

	public function step():Void {
		for (s in ss) {
			s.preSolve();
		}
		for (t in 0...8) {
			for (s in ss) {
				s.solve();
			}
		}
		for (s in ss) {
			s.postSolve();
		}
		for (p in ps) {
			p.move();
		}
	}
}
