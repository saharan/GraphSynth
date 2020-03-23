package graph;

import graph.serial.SocketTypeData;
import graph.serial.SocketData;

class Socket {
	@:allow(graph.Graph)
	var g:Graph;

	public final parent:Node;

	public final phys:SocketPhys;

	public var type:SocketType;

	public var connections:Array<SocketConnection> = [];
	public var prevConnections:Array<SocketConnection> = [];

	static var idCount:Int = 0;

	public final id:Int = ++idCount;

	public function new(g:Graph, parent:Node, type:SocketType) {
		this.g = g;
		this.parent = parent;
		this.type = type;
		phys = new SocketPhys(g, parent.phys, this);
	}

	public static function serializeType(type:SocketType, boundaries:Array<Node>):SocketTypeData {
		return switch (type) {
			case Normal(io):
				{
					normal: io
				}
			case Param(io, name):
				{
					param: {
						io: io,
						name: name
					}
				}
			case Module(io, boundary):
				{
					module: {
						io: io,
						boundaryNode: boundaries.indexOf(boundary)
					}
				}
		};
	}

	public static function deserializeType(data:SocketTypeData, boundaries:Array<Node>):SocketType {
		var count = 0;
		if (data.normal != null)
			count++;
		if (data.param != null)
			count++;
		if (data.module != null)
			count++;
		if (count != 1)
			throw "invalid socket type data: " + data;
		if (data.normal != null)
			return Normal(data.normal);
		if (data.param != null)
			return Param(data.param.io, data.param.name);
		if (data.module != null)
			return Module(data.module.io, boundaries[data.module.boundaryNode]);
		throw "!?";
	}

	public function serialize():SocketData {
		phys.computeDrawingPos();
		return {
			angle: phys.getAngle(),
			type: serializeType(type, parent.moduleBoundaries)
		};
	}
}
