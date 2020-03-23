package graph;

import phys.Point;

class Vertex {
	public var point(default, null):Point;
	public var edges:Array<Edge>;
	public var type:VertexType;

	static inline final MAX_LIFE:Int = 60;

	public var life:Int = MAX_LIFE;

	@:allow(graph.Graph)
	var tmpValForDfs:Int;

	@:allow(render.Renderer)
	public var tmpValForRendering:Int;

	static inline final CABLE_DAMPING:Float = 0.95;
	static inline final NODE_DAMPING:Float = 0.8;

	static var idCount:Int = 0;

	public var id:Int = ++idCount;

	@:allow(graph.Graph)
	function new(x:Float, y:Float, type:VertexType, invM:Float) {
		this.type = type;
		this.point = new Point(x, y, invM);
		point.damp = switch (type) {
			case Node(_) | Socket(_): NODE_DAMPING;
			case Normal: CABLE_DAMPING;
		}
		edges = [];
		tmpValForDfs = 0;
		tmpValForRendering = 0;
	}

	public function vibrate(strong:Bool = false):Void {
		var ang:Float = Math.random() * Math.PI * 2;
		var amp:Float = strong ? 10 : 2;
		var fx:Float = Math.cos(ang) * amp;
		var fy:Float = Math.sin(ang) * amp;
		for (e in edges) {
			var v = e.other(this);
			if (!v.type.match(Node(_))) {
				point.vx += fx;
				point.vy += fy;
				v.point.vx -= fx;
				v.point.vy -= fy;
				return;
			}
		}
	}

	public function followCable(prev:Vertex, out:CableInfo):Bool {
		if (edges.length == 1) {
			if (edges[0].other(this) != prev)
				throw "invalid prev point in cable";
			out.vertex = null;
			out.edge = null;
			return false; // end of cable
		}
		if (edges.length == 2) {
			var v1 = edges[0].other(this);
			var v2 = edges[1].other(this);
			if (v1 != prev && v2 != prev)
				throw "invalid prev point in cable";
			if (v1 != prev) {
				out.vertex = v1;
				out.edge = edges[0];
			} else {
				out.vertex = v2;
				out.edge = edges[1];
			}
			return true;
		}
		throw "cannot follow cable: edges=" + edges.length;
	}
}
