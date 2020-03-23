package graph;

class Module {
	public var nodes:Array<Node>;
	public var exposedSockets:Array<Socket>;

	public function new(nodes:Array<Node>, exposedSockets:Array<Socket>) {
		this.nodes = nodes;
		this.exposedSockets = exposedSockets;
	}
}
