package app.ui.view.main.graph.drag;

import graph.Node;

class NodeDragHandler implements DragHandler {
	final graph:GraphWrapper;
	final conn:VertexConnector;
	var nodes:Array<Node>;
	var shadows:Array<NodeShadow>;
	var anchorX:Float = 0;
	var anchorY:Float = 0;

	public function new(graph:GraphWrapper, nodes:Array<Node>, x:Float, y:Float) {
		this.graph = graph;
		this.nodes = nodes.copy();
		this.shadows = [];
		anchorX = x;
		anchorY = y;
		for (n in this.nodes) {
			var shadow = new NodeShadow(n);
			shadows.push(shadow);
			graph.addNodeShadow(shadow);
		}
		if (nodes.length == 1) {
			conn = new VertexConnector(graph, nodes[0].phys.vertex);
			conn.onTargetVertexUpdated = (prev, current) -> {
				shadows[0].hidden = current != null;
			}
		} else {
			conn = null;
		}
	}

	public function move(x:Float, y:Float):Void {
		var dx = x - anchorX;
		var dy = y - anchorY;
		for (shadow in shadows) {
			shadow.x = shadow.internal.getX() + dx;
			shadow.y = shadow.internal.getY() + dy;
		}
		if (nodes.length == 1) {
			conn.move(x, y);
		}
	}

	public function done():Void {
		// clear selection
		graph.selection.clear();
		for (node in nodes) {
			graph.selection.add(node);
		}

		// connect or move
		var move = true;
		if (conn != null) {
			move = !conn.isTryingToConnect();
			conn.done();
			if (conn.connected) {
				graph.doneOperation(Add);
			}
		}
		if (move) {
			var dx = shadows[0].getX() - nodes[0].getX();
			var dy = shadows[0].getY() - nodes[0].getY();
			graph.moveNodes(nodes, dx, dy);
			graph.doneOperation(Move);
		}

		// clear
		graph.clearConnectionShadows();
		graph.clearNodeShadows();
		shadows = null;
		nodes = null;
	}

	public function cancel():Void {
		if (conn != null) {
			conn.cancel();
		}

		graph.clearConnectionShadows();
		graph.clearNodeShadows();
		shadows = null;
		nodes = null;
	}
}
