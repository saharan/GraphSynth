package graph;

import app.event.Dispatcher;
import graph.serial.NodeData;
import graph.serial.NodeFilter;
import graph.serial.NodeTypeData;
import graph.serial.SocketData;
import synth.NodeRole;

class Node extends Dispatcher<NodeUpdateListener> implements NodeViewData {
	@:allow(graph.Graph)
	var g:Graph;

	public final phys:NodePhys;

	public var type(default, null):NodeType;
	public final sockets:Array<Socket>;
	public final selection:Selection;

	public final setting:NodeSetting;

	public var moduleGraph:Graph;
	public var moduleBoundaries:Array<Node>;

	static var idCount:Int = 0;

	public final id:Int = ++idCount;

	public function new(g:Graph, x:Float, y:Float, type:NodeType, setting:NodeSetting) {
		this.g = g;
		this.type = type;
		this.setting = setting;
		switch (type) {
			case Module(_):
				moduleGraph = new Graph(g.listener);
				moduleGraph.parentModule = this;
				moduleBoundaries = [];
			case _:
		}
		phys = new NodePhys(g, this, x, y);
		sockets = [];
		selection = new Selection();
	}

	public function boundaryToNormal():Void {
		if (!type.match(Boundary(_)))
			throw "not a boundary node";
		phys.toSmall();
		type = Small;
		setting.name = "";
		setting.role = Dupl;
		notifyUpdate();
	}

	public function createSocket(type:SocketType):Socket {
		var ok:Bool = switch (type) {
			case Param(_):
				switch (this.type) {
					case Small | Boundary(_) | Module(_):
						false;
					case Normal(_):
						true;
				}
			case Module(_):
				switch (this.type) {
					case Small | Boundary(_) | Normal(_):
						true;
					case Module(_):
						true;
				}
			case Normal(I):
				switch (this.type) {
					case Normal(input, _):
						input;
					case Module(input, _):
						input;
					case Small:
						true;
					case Boundary(type):
						type == I;
				}
			case Normal(O):
				switch (this.type) {
					case Normal(_, output):
						output;
					case Module(_, output):
						output;
					case Small:
						true;
					case Boundary(type):
						type == O;
				}
		}
		if (!ok)
			throw "cannot create socket";

		var reference = switch (this.type) {
			case Module(_):
				switch (type) {
					case Normal(_):
						throw "not implemented yet";
					case Param(_):
						throw "module node cannot have param socket";
					case Module(_, boundary):
						boundary;
				};
			case _:
				this;
		}

		var s:Socket = new Socket(g, this, type);
		sockets.push(s);
		g.listener.onSocketCreated(s.id, reference.id, reference != this ?Normal(s.type.io()):s.type);
		return s;
	}

	public function destroySocket(s:Socket):Void {
		var conns = s.connections.copy();
		for (c in conns) {
			var s1 = c.from;
			var s2 = c.to;
			g.listener.onSocketDisconnected(s1.id, s2.id);
			s1.connections.remove(c);
			s2.connections.remove(c);
		}
		g.listener.onSocketDestroyed(s.id);
		g.destroyVertexUnsafe(s.phys.vertex);
		sockets.remove(s);
	}

	public function notifyUpdate():Void {
		var adjustSize = !type.match(Small) && !setting.role.match(Destination);
		// adjust physical node size
		if (adjustSize) {
			var nameLength = getText().length;

			if (type.match(Boundary(_)))
				nameLength++;

			var scale:Float = nameLength > 3 ? 1.0 + (nameLength - 3) * 0.25 : 1.0;
			phys.changeScale(scale);
		}

		updateSockets();

		// notify updates
		dispatch(l -> l.onNodeUpdate(this));
		if (!type.match(Module(_)))
			g.listener.onNodeUpdated(this.id);
	}

	function updateSockets():Void {
		var disabledNames:Array<String> = [];
		switch setting.role {
			case Frequency:
			case Oscillator(type):
			case Destination:
			case Delay:
			case Filter(type):
				switch type {
					case LowPass | HighPass | BandPass | BandStop:
						disabledNames.push("gain");
					case LowShelf | HighShelf:
						disabledNames.push("Q");
					case Peak:
				}
			case Compressor:
			case Envelope(env):
			case Number(num):
			case BinOp(type):
			case Dupl:
			case None:
		}
		for (s in sockets) {
			s.grayedOut = switch s.type {
				case Param(_, name):
					disabledNames.indexOf(name) != -1;
				case _:
					false;
			}
		}
	}

	public static function serializeType(type:NodeType):NodeTypeData {
		return switch (type) {
			case Normal(input, output):
				{
					normal: {
						input: input,
						output: output
					}
				}
			case Module(input, output):
				{
					module: {
						input: input,
						output: output
					}
				}
			case Small:
				{
					small: Null
				}
			case Boundary(io):
				{
					boundary: io
				}
		};
	}

	public static function deserializeType(data:NodeTypeData):NodeType {
		var count = 0;
		if (data.normal != null)
			count++;
		if (data.module != null)
			count++;
		if (data.boundary != null)
			count++;
		if (data.small != null)
			count++;
		if (count != 1)
			throw "invalid node type data: " + data;
		if (data.normal != null)
			return Normal(data.normal.input, data.normal.output);
		if (data.module != null)
			return Module(data.module.input, data.module.output);
		if (data.boundary != null)
			return Boundary(data.boundary);
		if (data.small != null)
			return Small;
		throw "!?";
	}

	public function serialize(filter:NodeFilter, keepIds:Bool):NodeData {
		var sockets:Array<SocketData> = [];
		for (s in this.sockets) {
			var isNormal = s.type.match(Normal(_));
			if (isNormal) {
				// TODO: this breaks socket indices
				/* 
					if (excludeNonParamSockets)
						continue;
					// filter normal sockets
					var hasConnection = false;
					for (conn in s.connections) {
						if (filter.containNode(conn.other(s).parent))
							hasConnection = true;
					}
					if (!hasConnection)
						continue;
				 */
			}
			sockets.push(s.serialize());
		}
		var data:NodeData = {
			x: phys.vertex.point.x,
			y: phys.vertex.point.y,
			type: serializeType(type),
			setting: setting.serialize(),
			sockets: sockets
		};
		if (type.match(Module(_))) {
			data.graph = moduleGraph.serialize(NodeFilter.ALL, keepIds);
			data.boundaries = moduleBoundaries.map(boundary -> moduleGraph.nodes.indexOf(boundary));
		}
		return data;
	}

	// --------------------------

	public inline function getX():Float {
		return phys.vertex.point.x;
	}

	public inline function getY():Float {
		return phys.vertex.point.y;
	}

	public inline function getRadius():Float {
		return phys.radius;
	}

	public inline function getText():String {
		return switch (setting.role) {
			case Number(num):
				num.toString();
			case _:
				setting.name;
		}
	}

	public inline function getRole():NodeRole {
		return setting.role;
	}

	public inline function getType():NodeType {
		return type;
	}
}
