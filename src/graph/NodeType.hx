package graph;

@:using(graph.NodeType.NodeTypeTools)
enum NodeType {
	Normal(input:Bool, output:Bool); // normal nodes
	Module(input:Bool, output:Bool); // module containing other nodes
	Small; // small node such as add, mult, ...
	Boundary(io:IO); // boundary node for modules
}

class NodeTypeTools {
	public static function canCreateInput(type:NodeType):Bool {
		return switch type {
			case Normal(input, _):
				input;
			case Module(input, _):
				input;
			case Small:
				true;
			case Boundary(io):
				io == I;
		}
	}

	public static function canCreateOutput(type:NodeType):Bool {
		return switch type {
			case Normal(_, output):
				output;
			case Module(_, output):
				output;
			case Small:
				true;
			case Boundary(io):
				io == O;
		}
	}
}
