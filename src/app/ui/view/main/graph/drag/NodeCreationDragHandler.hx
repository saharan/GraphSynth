package app.ui.view.main.graph.drag;

import app.ui.view.menu.nodeedit.NodeEditMenu;
import graph.Graph;
import graph.serial.NodeFilter;

class NodeCreationDragHandler implements DragHandler {
	final graph:GraphWrapper;
	final info:NodeInfo;
	final pasteHandler:GraphPasteHandler;

	public function new(graph:GraphWrapper, info:NodeInfo, x:Float, y:Float) {
		this.graph = graph;
		this.info = info;

		var dummyGraph = new Graph();
		info.create(dummyGraph, 0, 0, true);
		var data = dummyGraph.serialize(NodeFilter.ALL, false);
		pasteHandler = new GraphPasteHandler(graph, data, x, y);
	}

	public function move(x:Float, y:Float):Void {
		pasteHandler.move(x, y);
	}

	public function done():Void {
		pasteHandler.done();
		var node = pasteHandler.pastedNodes[0];
		switch node.setting.role {
			case Envelope(_) | Number(_):
				graph.op.openMenu(new NodeEditMenu(node, graph));
			case _:
		}
	}

	public function cancel():Void {
		pasteHandler.cancel();
	}
}
