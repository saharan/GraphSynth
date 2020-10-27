package graph;

import synth.NodeRole;

interface NodeViewData {
	function getX():Float;
	function getY():Float;
	function getRadius():Float;
	function getText():String;
	function getRole():NodeRole;
	function getType():NodeType;
}
