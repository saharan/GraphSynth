package graph;

import phys.Spring;

class Edge {
	public var spring(default, null):Spring;
	public var v1(default, null):Vertex;
	public var v2(default, null):Vertex;

	public var firstEdgeOf:SocketConnection;
	public var lastEdgeOf:SocketConnection;

	@:allow(graph.Graph)
	function new(v1:Vertex, v2:Vertex, length:Float, stiff:Bool) {
		this.v1 = v1;
		this.v2 = v2;
		spring = new Spring(v1.point, v2.point, length, stiff);
		firstEdgeOf = null;
		lastEdgeOf = null;
	}

	@:allow(graph.Graph)
	function connect():Void {
		v1.edges.push(this);
		v2.edges.push(this);
	}

	@:allow(graph.Graph)
	function disconnect():Void {
		var ok:Bool = true;
		ok = ok && v1.edges.remove(this);
		ok = ok && v2.edges.remove(this);
		if (!ok)
			throw "couldn't disconnect";
	}

	extern public inline function other(v:Vertex):Vertex {
		return v != v1 ? v1 : v2;
	}
}
