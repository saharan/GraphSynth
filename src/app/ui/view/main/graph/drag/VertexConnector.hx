package app.ui.view.main.graph.drag;

import graph.Vertex;

class VertexConnector implements DragHandler {
	final graph:GraphWrapper;
	final vertex:Vertex;
	var connectionShadow:ConnectionShadow = null;
	var prevTarget:Vertex = null;

	public var connected(default, null):Bool = false;

	public var onTargetVertexUpdated:(prev:Vertex, current:Vertex) -> Void = null;

	public function new(graph:GraphWrapper, vertex:Vertex) {
		this.graph = graph;
		this.vertex = vertex;
	}

	public function move(x:Float, y:Float):Void {
		var pick = graph.pickWithCurrentScale(x, y, Connectable);
		var checkRes = graph.connectableChecker.check(vertex, pick);
		targetTo(checkRes.vertex(), checkRes.ok());
	}

	public function isTryingToConnect():Bool {
		return connectionShadow != null;
	}

	public function done():Void {
		connected = false;
		if (connectionShadow != null) {
			if (connectionShadow.ok) {
				connected = true;
				GraphWrapper.connectVerticesMakingSockets(graph.raw, connectionShadow.v1, connectionShadow.v2);
			}
		}
		targetTo(null, false);
	}

	public function cancel():Void {
		targetTo(null, false);
	}

	function targetTo(v:Vertex, ok:Bool):Void {
		if (v == null) {
			connectionShadow = null;
			graph.clearConnectionShadows();
		} else {
			if (connectionShadow == null) {
				connectionShadow = new ConnectionShadow(vertex, v, ok);
				graph.addConnectionShadow(connectionShadow);
			} else {
				connectionShadow.v1 = vertex;
				connectionShadow.v2 = v;
				connectionShadow.ok = ok;
			}
		}

		if (prevTarget != v) {
			if (prevTarget != null) {
				switch prevTarget.type {
					case Node(n):
					case Socket(s):
						graph.socketSelection.remove(s);
					case Normal:
				}
			}
			if (v != null) {
				switch v.type {
					case Node(n):
					case Socket(s):
						graph.socketSelection.add(s);
					case Normal:
				}
			}
			if (onTargetVertexUpdated != null)
				onTargetVertexUpdated(prevTarget, v);
			prevTarget = v;
		}
	}
}
