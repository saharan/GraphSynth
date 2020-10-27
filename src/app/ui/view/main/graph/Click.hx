package app.ui.view.main.graph;

import app.ui.view.main.graph.ClickSettings.*;
import app.ui.view.main.graph.drag.CableDragHandler;
import app.ui.view.main.graph.drag.GraphPasteHandler;
import app.ui.view.main.graph.drag.NodeCreationDragHandler;
import app.ui.view.main.graph.drag.NodeDragHandler;
import app.ui.view.main.graph.drag.SocketDragHandler;
import graph.serial.GraphData;

class Click {
	public final graph:GraphWrapper;

	var nodeToCreate:NodeInfo = null;
	var dataToPaste:GraphData = null;
	var state:ClickState = Idle;

	public function new(graph:GraphWrapper) {
		this.graph = graph;
	}

	public function reset():Void {
		graph.trail.clear();
		state = Idle;
	}

	public function gotoNodeCreationMode(n:NodeInfo):Void {
		nodeToCreate = n;
		dataToPaste = null;
		graph.op.showInfo("Tap to add: " + n.fullName, Persistent);
	}

	public function gotoPasteMode(data:GraphData, verb:String):Void {
		dataToPaste = data;
		nodeToCreate = null;
		graph.op.showInfo("Tap to " + verb, Persistent);
	}

	public function begin(x:Float, y:Float):Void {
		graph.trail.begin(x, y);
		graph.op.closeToolbar();

		switch state {
			case Idle:
				if (nodeToCreate != null)
					state = Dragging(new NodeCreationDragHandler(graph, nodeToCreate, x, y));
				else if (dataToPaste != null)
					state = Dragging(new GraphPasteHandler(graph, dataToPaste, x, y));
				else
					state = ClickOn(clickAt(x, y));
			case _:
				throw "invalid click";
		}
	}

	function clickAt(x:Float, y:Float):ClickTarget {
		var v = graph.pickWithCurrentScale(x, y, All);
		if (v == null)
			return None;
		return switch v.type {
			case Node(n):
				Node(n);
			case Socket(s):
				Socket(s);
			case Normal:
				CableVertex(v); // need confirmation??
		}
	}

	public function move(x:Float, y:Float):Void {
		switch state {
			case Idle:
				throw "cannot move before begin";
			case ClickOn(target):
				var initial = graph.trail.firstPos();
				var dx = x - initial.x;
				var dy = y - initial.y;
				var dist = Math.sqrt(dx * dx + dy * dy);
				if (dist > pxToWorld(DRAG_BEGIN_THRESHOLD_PX)) {
					clickToDrag(target, initial.x, initial.y);
				}
			case Dragging(handler):
				handler.move(x, y);
			case Trailing:
				graph.trail.move(x, y, graph.view.scale);
		}
	}

	extern inline function pxToWorld(px:Float):Float {
		return px / graph.view.scale;
	}

	public function clickToDrag(target:ClickTarget, x:Float, y:Float):Void {
		switch target {
			case Node(n):
				var nodes = [];
				if (graph.selection.contains(n)) {
					graph.selection.forEach(node -> nodes.push(node));
				} else {
					if (graph.op.getKeyboard().isShiftDown()) {
						graph.selection.forEach(node -> nodes.push(node));
					} else {
						graph.selection.clear();
					}
					graph.selection.add(n);
					nodes.push(n);
				}
				state = Dragging(new NodeDragHandler(graph, nodes, x, y));
			case Socket(s):
				state = Dragging(new SocketDragHandler(graph, s));
			case CableVertex(v):
				state = Dragging(new CableDragHandler(graph, v));
			case None:
				state = Trailing;
		}
	}

	public function end():Void {
		switch state {
			case Idle:
				throw "invalid click end event";
			case ClickOn(target): // click
				switch target {
					case Node(n):
						if (graph.op.getKeyboard().isShiftDown()) {
							// switch selection
							if (graph.selection.contains(n))
								graph.selection.remove(n);
							else
								graph.selection.add(n);
						} else if (graph.selection.count() == 1 && graph.selection.contains(n)) {
							graph.interact(n);
						} else {
							// select a single node
							graph.selection.clear();
							graph.selection.add(n);
						}
					case Socket(s):
					case CableVertex(v):
					case None:
						// clicked empty, clear selection
						graph.selection.clear();
				}
			case Dragging(handler):
				handler.done();
				nodeToCreate = null;
				dataToPaste = null;
				graph.op.hideInfo();
			case Trailing:
				if (graph.trail.isLasso) {
					graph.trail.selectByLasso(graph.selection, graph.nodes);
				} else {
					// remove slashed vertices
					var cutVertices = graph.trail.getSlashedVertices(graph.nodes, graph.vertices).filter(graph.canDestroyVertex);
					if (graph.destroyVertices(cutVertices, true)) {
						graph.doneOperation(Remove);
					}
				}
		}
		reset();
	}

	public function cancel():Void {
		switch state {
			case Idle:
			case ClickOn(target):
			case Dragging(handler):
				handler.cancel();
			case Trailing:
		}
		reset();
	}
}
