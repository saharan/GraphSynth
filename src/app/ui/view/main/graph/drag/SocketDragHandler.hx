package app.ui.view.main.graph.drag;

import phys.Point;
import graph.Socket;

class SocketDragHandler implements DragHandler {
	final graph:GraphWrapper;
	final socket:Socket;
	final conn:VertexConnector;
	final point:Point;

	public function new(graph:GraphWrapper, socket:Socket) {
		this.graph = graph;
		this.socket = socket;
		conn = new VertexConnector(graph, socket.phys.vertex);
		graph.socketSelection.add(socket);
		point = socket.phys.vertex.point;
	}

	public function move(x:Float, y:Float):Void {
		// apply force to socket vertex
		var dx = x - point.x;
		var dy = y - point.y;
		var l = Math.sqrt(dx * dx + dy * dy);
		var invL = l > 0 ? 1 / l : 0;
		var nx = dx * invL;
		var ny = dy * invL;
		var f = l * 0.1;
		if (f > 1)
			f = 1;
		point.vx += nx * f;
		point.vy += ny * f;
		conn.move(x, y);
	}

	public function done():Void {
		conn.done();
		if (conn.connected) {
			graph.doneOperation(Add);
		}
		graph.socketSelection.remove(socket);
	}

	public function cancel():Void {
		conn.cancel();
		graph.socketSelection.remove(socket);
	}
}
