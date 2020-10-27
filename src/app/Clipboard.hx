package app;

import graph.serial.NodeFilter;
import graph.Graph;
import graph.serial.GraphData;

class Clipboard {
	public var data(default, null):GraphData;

	public function new() {
		data = null;
	}

	public function copy(data:GraphData):Void {
		var g = Graph.deserialize(data);
		g.moveCenterToZero();
		this.data = g.serialize(NodeFilter.ALL, false);
	}
}
