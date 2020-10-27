package app.ui.view.main.graph;

import graph.Vertex;

class ConnectableChecker {
	final graph:GraphWrapper;

	public function new(graph:GraphWrapper) {
		this.graph = graph;
	}

	public function check(from:Vertex, to:Vertex):ConnectableCheckResult {
		if (from == null || to == null)
			return Ignore;
		var rel = graph.relation(from, to);
		if (rel == Same)
			return Ignore;
		var canConnect = rel == Connectable;
		return switch to.type {
			case Node(n):
				TryNode(n, canConnect);
			case Socket(s):
				TrySocket(s, canConnect);
			case Normal:
				TryCable(to, canConnect);
		}
	}
}
