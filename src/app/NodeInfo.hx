package app;

import graph.Node;
import graph.NodeSetting;
import graph.Graph;
import graph.NodeOption;
import graph.NodeType;
import synth.NodeRole;

class NodeInfo {
	public final fullName:String;
	public final labelName:String;
	public final type:NodeType;
	public final role:NodeRole;
	public final inParams:Array<String>;
	public final outParams:Array<String>;

	public function new(fullName:String, labelName:String, type:NodeType, role:NodeRole, inParams:Array<String>, outParams:Array<String>) {
		this.fullName = fullName;
		this.labelName = labelName;
		this.type = type;
		this.role = role;
		this.inParams = inParams;
		this.outParams = outParams;
	}

	public function create(g:Graph, x:Float, y:Float):Node {
		var node = g.createNode(x, y, type, new NodeSetting(labelName, role.copy()));
		var ang = 0.0;
		for (p in inParams) {
			var sp = node.createSocket(Param(I, p)).phys;
			sp.setNormal(-Math.cos(ang), Math.sin(ang));
			ang += Math.PI / 6;
		}
		ang = 0;
		for (p in outParams) {
			var sp = node.createSocket(Param(I, p)).phys;
			sp.setNormal(Math.cos(ang), Math.sin(ang));
			ang += Math.PI / 6;
		}
		return node;
	}
}
