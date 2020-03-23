package app;

import graph.Graph;
import graph.Node;
import graph.serial.NodeData;

class Clipboard {
	var nodeData:NodeData;

	public function new() {
		nodeData = null;
	}

	public function copyNode(node:Node):Void {
		nodeData = node.serialize(true);
	}

	public function hasData():Bool {
		return nodeData != null;
	}

	public function pasteNode(graph:Graph, atX:Float, atY:Float):Void {
		graph.createNodeByDataAt(atX, atY, nodeData);
	}
}
