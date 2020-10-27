package graph;

class SocketConnection {
	public var from:Socket;
	public var to:Socket;
	public var firstEdge:Edge;
	public var lastEdge:Edge;

	public function new(from:Socket, to:Socket, firstEdge:Edge, lastEdge:Edge) {
		this.from = from;
		this.to = to;
		this.firstEdge = firstEdge;
		this.lastEdge = lastEdge;
	}

	public function other(s:Socket):Socket {
		return s != from ? from : to;
	}

	public function nearestEdge(s:Socket):Edge {
		return s == from ? firstEdge : lastEdge;
	}

	public function getIntermediateVertices():Array<Vertex> {
		var res:Array<Vertex> = [];
		var prevV = firstEdge.v1;
		var v = firstEdge.v2;
		var info = new CableInfo();
		while (v != lastEdge.v2) {
			res.push(v);
			v.followCable(prevV, info);
			prevV = v;
			v = info.vertex;
		}
		return res;
	}

	public static function indexOf(array:Array<SocketConnection>, from:Socket, to:Socket):Int {
		for (i in 0...array.length) {
			var c = array[i];
			if (c.from == from && c.to == to)
				return i;
		}
		return -1;
	}
}
