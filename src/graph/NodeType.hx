package graph;

enum NodeType {
	Normal(input:Bool, output:Bool); // normal nodes
	Module(input:Bool, output:Bool); // module containing other nodes
	Small; // small node such as add, mult, ...
	Boundary(io:IO); // boundary node for modules
}
