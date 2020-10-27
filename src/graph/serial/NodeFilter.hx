package graph.serial;

class NodeFilter {
	public static final ALL = new NodeFilter(_ -> true);
	public static final NONE = new NodeFilter(_ -> false);

	public final containNode:Node->Bool;

	public function new(containNode:Node->Bool) {
		this.containNode = containNode;
	}

	public static function single(node:Node):NodeFilter {
		return new NodeFilter(n -> n == node);
	}
}
