package graph;

import graph.serial.SocketConnectionData;

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

	public static function indexOf(array:Array<SocketConnection>, from:Socket, to:Socket):Int {
		for (i in 0...array.length) {
			var c = array[i];
			if (c.from == from && c.to == to)
				return i;
		}
		return -1;
	}
}
