package common;

class Set<A:{}> {
	final map:Map<A, Any>;
	var numEntries:Int;

	public function new() {
		map = new Map<A, Any>();
		numEntries = 0;
	}

	public function toArray():Array<A> {
		var res = [];
		forEach(a -> res.push(a));
		return res;
	}

	public inline function forEach(f:A->Void):Void {
		for (a in map.keys()) {
			f(a);
		}
	}

	public function add(a:A):Bool {
		if (contains(a))
			return false;
		numEntries++;
		map[a] = null;
		return true;
	}

	public function remove(a:A):Bool {
		if (!contains(a))
			return false;
		numEntries--;
		map.remove(a);
		return true;
	}

	public function count():Int {
		return numEntries;
	}

	public inline function clear():Void {
		map.clear();
		numEntries = 0;
	}

	public inline function contains(a:A):Bool {
		return map.exists(a);
	}
}
