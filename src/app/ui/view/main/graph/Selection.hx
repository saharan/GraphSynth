package app.ui.view.main.graph;

import common.Set;
import graph.Node;
import graph.serial.GraphData;
import graph.serial.NodeFilter;

class Selection {
	final graph:GraphWrapper;
	final nodes:Set<Node>;

	public function new(graph:GraphWrapper) {
		this.graph = graph;
		nodes = new Set();
	}

	public function createSubgraphData(editableOnly:Bool):GraphData {
		return graph.raw.serialize(new NodeFilter(n -> (!editableOnly || graph.isEditableNode(n)) && contains(n)), false);
	}

	public function toArray():Array<Node> {
		return nodes.toArray();
	}

	public inline function forEach(f:Node->Void):Void {
		return nodes.forEach(f);
	}

	public function add(a:Node):Bool {
		return nodes.add(a);
	}

	public function remove(a:Node):Bool {
		return nodes.remove(a);
	}

	public function count():Int {
		return nodes.count();
	}

	public inline function clear():Void {
		return nodes.clear();
	}

	public inline function contains(a:Node):Bool {
		return nodes.contains(a);
	}
}
