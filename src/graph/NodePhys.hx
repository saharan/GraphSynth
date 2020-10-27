package graph;

class NodePhys {
	public static inline final DEFAULT_RADIUS:Float = 12;
	static inline final SMALL_NODE_INV_MASS:Float = 0; // 1 / 10.0;
	static inline final NORMAL_NODE_INV_MASS:Float = 0;

	public final node:Node;
	public var vertex:Vertex;
	public var radius:Float;

	public var drawingRadiusOffset(default, set):Float;

	var scale:Float;

	public function new(g:Graph, node:Node, x:Float, y:Float) {
		this.node = node;
		vertex = g.createVertex(x, y, Node(node), switch (node.type) {
			case Small: SMALL_NODE_INV_MASS;
			case _: NORMAL_NODE_INV_MASS;
		});
		scale = switch (node.type) {
			case Small: 0.5;
			case _:
				switch (node.setting.role) {
					case Destination: 3.0;
					case _: 1.0;
				}
		};
		drawingRadiusOffset = 0;
	}

	@:allow(graph.Node)
	function toSmall():Void {
		vertex.point.invM = SMALL_NODE_INV_MASS;
		changeScale(0.5);
	}

	@:allow(graph.Node)
	function changeScale(s:Float = 1.0):Void {
		scale = s;
		radius = DEFAULT_RADIUS * s + drawingRadiusOffset;
		if (node.sockets != null) {
			for (s in node.sockets) {
				s.phys.edge.spring.length = radius + s.phys.radius * 2;
			}
		}
	}

	function set_drawingRadiusOffset(v:Float):Float {
		drawingRadiusOffset = v;
		changeScale(scale);
		return v;
	}
}
