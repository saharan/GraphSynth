package app.ui.view.main.graph.drag;

import graph.Vertex;

class CableDragHandler implements DragHandler {
	final conn:VertexConnector;
	final graph:GraphWrapper;

	public function new(graph:GraphWrapper, vertex:Vertex) {
		this.graph = graph;
		conn = new VertexConnector(graph, vertex);
	}

	public function move(x:Float, y:Float):Void {
		conn.move(x, y);
	}

	public function done():Void {
		conn.done();
		if (conn.connected) {
			graph.doneOperation(Add);
		}
	}

	public function cancel():Void {
		conn.cancel();
	}
}
