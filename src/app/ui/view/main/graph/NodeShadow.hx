package app.ui.view.main.graph;

import graph.NodeType;
import synth.NodeRole;
import graph.NodeViewData;

class NodeShadow implements NodeViewData {
	public final internal:NodeViewData;
	public var x:Float;
	public var y:Float;
	public var hidden:Bool;

	public function new(internal:NodeViewData) {
		this.internal = internal;
		x = internal.getX();
		y = internal.getY();
		hidden = false;
	}

	public function getX():Float {
		return x;
	}

	public function getY():Float {
		return y;
	}

	public function getRadius():Float {
		return internal.getRadius();
	}

	public function getText():String {
		return internal.getText();
	}

	public function getRole():NodeRole {
		return internal.getRole();
	}

	public function getType():NodeType {
		return internal.getType();
	}
}
