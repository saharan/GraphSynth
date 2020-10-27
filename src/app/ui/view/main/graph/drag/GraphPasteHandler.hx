package app.ui.view.main.graph.drag;

import graph.serial.NodeFilter;
import graph.Node;
import graph.Graph;
import graph.serial.GraphData;

class GraphPasteHandler implements DragHandler {
	final graph:GraphWrapper;
	public var pastedNodes(default, null):Array<Node>;
	var data:GraphData;
	var shadows:Array<NodeShadow>;
	var offsetX:Float = 0;
	var offsetY:Float = 0;

	public function new(graph:GraphWrapper, data:GraphData, x:Float, y:Float) {
		this.graph = graph;
		this.data = data;
		shadows = [];

		var dummyGraph = Graph.deserialize(data);
		for (node in dummyGraph.nodes) {
			var shadow = new NodeShadow(node);
			shadow.x += x;
			shadow.y += y;
			shadows.push(shadow);
			graph.addNodeShadow(shadow);
		}
		offsetX = x;
		offsetY = y;
		pastedNodes = null;
	}

	public function move(x:Float, y:Float):Void {
		for (shadow in shadows) {
			shadow.x = shadow.internal.getX() + x;
			shadow.y = shadow.internal.getY() + y;
		}
		offsetX = x;
		offsetY = y;
	}

	public function done():Void {
		graph.selection.clear();
		var nodes = Graph.deserializeInto(graph.raw, offsetX, offsetY, data);
		for (n in nodes) {
			graph.selection.add(n);
		}
		pastedNodes = nodes;
		graph.doneOperation(Paste);

		// clear
		graph.clearNodeShadows();
		data = null;
		shadows = null;
	}

	public function cancel():Void {
		graph.clearNodeShadows();
		data = null;
		shadows = null;
	}
}
