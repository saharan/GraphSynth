package app;

import graph.Graph;
import app.ui.view.main.graph.GraphWrapper;
import graph.Node;
import graph.NodePhys;
import graph.NodeSetting;
import graph.NodeType;
import synth.NodeRole;

class NodeInfo {
	public final fullName:String;
	public final labelName:String;
	public final type:NodeType;
	public final role:NodeRole;
	public final inParams:Array<NodeInputParamInfo>;
	public final outParams:Array<NodeOutputParamInfo>;

	public static inline final ANGLE_SPACING:Float = 3.141592653589793 / 5;

	public function new(fullName:String, labelName:String, type:NodeType, role:NodeRole, inParams:Array<NodeInputParamInfo>,
			outParams:Array<NodeOutputParamInfo>) {
		this.fullName = fullName;
		this.labelName = labelName;
		this.type = type;
		this.role = role;
		this.inParams = inParams;
		this.outParams = outParams;
	}

	public function create(g:Graph, x:Float, y:Float, addNumberNodes:Bool):Node {
		var node = g.createNode(x, y, type, new NodeSetting(labelName, role.copy()));
		createInParams(g, node, addNumberNodes);
		createOutParams(g, node);
		return node;
	}

	function createInParams(g:Graph, node:Node, addNumberNodes:Bool):Void {
		var numParams = inParams.length;
		var angTotal = (numParams - 1) * ANGLE_SPACING;
		var ang = -angTotal / 2;
		var distance = 80;
		for (p in inParams) {
			var sp = node.createSocket(Param(I, p.name)).phys;
			var nx = -Math.cos(ang);
			var ny = Math.sin(ang);
			sp.setNormal(nx, ny);

			if (p.defaultValue != null && addNumberNodes) {
				var x = node.getX() + nx * distance;
				var y = node.getY() + ny * distance;
				var number = NodeList.numberOfValue(p.defaultValue).create(g, x, y, false);
				GraphWrapper.connectVerticesMakingSockets(g, number.phys.vertex, sp.vertex);
			}
			ang += ANGLE_SPACING;
		}
	}

	function createOutParams(g:Graph, node:Node):Void {
		var numParams = outParams.length;
		var angTotal = (numParams - 1) * ANGLE_SPACING;
		var ang = -angTotal / 2;
		for (p in outParams) {
			var sp = node.createSocket(Param(I, p.name)).phys;
			sp.setNormal(Math.cos(ang), Math.sin(ang));
			ang += ANGLE_SPACING;
		}
	}
}
