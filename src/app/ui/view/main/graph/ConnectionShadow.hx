package app.ui.view.main.graph;

import graph.Vertex;

class ConnectionShadow {
	public var v1:Vertex;
	public var v2:Vertex;
	public var ok:Bool;

	public function new(v1:Vertex, v2:Vertex, ok:Bool) {
		this.v1 = v1;
		this.v2 = v2;
		this.ok = ok;
	}
}
