package graph;

import js.html.CanvasElement;

class SocketPhys {
	public static inline final RADIUS_SMALL:Float = 2.0;
	public static inline final RADIUS_LARGE:Float = 4.0;
	static inline final INV_MASS:Float = 1 / 5.0;

	public final socket:Socket;

	final nodePhys:NodePhys;

	public var radius:Float;
	public var vertex:Vertex;
	public var edge:Edge;
	public var xForDrawing:Float;
	public var yForDrawing:Float;
	public var normalX:Float;
	public var normalY:Float;
	public var labels:Array<CanvasElement>;
	public var labelText:String;

	public function new(g:Graph, nodePhys:NodePhys, socket:Socket) {
		this.socket = socket;
		this.nodePhys = nodePhys;
		radius = switch (socket.type) {
			case Normal(_): RADIUS_SMALL;
			case Param(_) | Module(_): RADIUS_LARGE;
		};
		vertex = g.createVertex(nodePhys.vertex.point.x + Math.random() * 2 - 1, nodePhys.vertex.point.y + Math.random() * 2 - 1,
			Socket(socket), INV_MASS);
		edge = g.createEdge(nodePhys.vertex, vertex, nodePhys.radius + radius * 2);
		xForDrawing = 0;
		yForDrawing = 0;
		normalX = 0;
		normalY = 0;
		labels = null;
		labelText = "";
	}

	public function setNormal(nx:Float, ny:Float):Void {
		vertex.point.x = nodePhys.vertex.point.x + nx * (nodePhys.radius + radius * 2);
		vertex.point.y = nodePhys.vertex.point.y + ny * (nodePhys.radius + radius * 2);
	}

	public function getAngle():Float {
		computeDrawingPos();
		return Math.atan2(normalY, normalX);
	}

	public function setAngle(angle:Float):Void {
		setNormal(Math.cos(angle), Math.sin(angle));
	}

	public function lookAt(x:Float, y:Float):Void {
		var dx:Float = x - nodePhys.vertex.point.x;
		var dy:Float = y - nodePhys.vertex.point.y;
		var d:Float = Math.sqrt(dx * dx + dy * dy);
		var invD:Float = d == 0 ? 0 : 1 / d;
		setNormal(dx * invD, dy * invD);
	}

	public function computeDrawingPos():Void {
		var sx:Float = vertex.point.x;
		var sy:Float = vertex.point.y;
		var nx:Float = nodePhys.vertex.point.x;
		var ny:Float = nodePhys.vertex.point.y;
		var dx:Float = sx - nx;
		var dy:Float = sy - ny;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		var invDist:Float = dist == 0 ? 0 : 1 / dist;
		normalX = dx * invDist;
		normalY = dy * invDist;
		xForDrawing = sx - normalX * radius;
		yForDrawing = sy - normalY * radius;
	}
}
