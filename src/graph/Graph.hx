package graph;

import render.View;
import graph.serial.SocketConnectionData;
import graph.serial.NodeData;
import graph.serial.GraphData;
import phys.World;

private class EmptyGraphListener implements GraphListener {
	public function new() {}

	public function onNodeCreated(id:Int, setting:NodeSetting):Void {}

	public function onNodeDestroyed(id:Int):Void {}

	public function onSocketCreated(id:Int, nodeId:Int, type:SocketType):Void {}

	public function onSocketDestroyed(id:Int):Void {}

	public function onSocketConnected(id1:Int, id2:Int):Void {}

	public function onSocketDisconnected(id1:Int, id2:Int):Void {}

	public function onNodeUpdated(id:Int):Void {}

	public function onWaveDataRequest(arrayOut:Array<Float>):Void {}
}

class Graph {
	public static inline final CABLE_LENGTH:Float = 4.0;
	public static inline final MARGIN:Float = 1.0;
	public static inline final CABLE_MASS:Float = 0.5;

	final world:World;

	public final nodes:Array<Node>;
	public final vertices:Array<Vertex>;
	public final edges:Array<Edge>;

	static var dfsCount:Int = 1;

	public var updateRequired(default, null):Bool;

	public var listener:GraphListener;

	public var parent:Graph;

	public function new(listener:GraphListener = null) {
		this.listener = listener != null ? listener : new EmptyGraphListener();
		world = new World();
		nodes = [];
		vertices = [];
		edges = [];
	}

	public function bakeView(view:View):Void {
		for (v in vertices) {
			v.point.x -= view.centerX;
			v.point.y -= view.centerY;
		}
		view.centerX = 0;
		view.centerY = 0;
	}

	public function createNode(x:Float, y:Float, type:NodeType, setting:NodeSetting):Node {
		var n:Node = new Node(this, x, y, type, setting);
		nodes.push(n);
		if (!n.type.match(Module(_)))
			listener.onNodeCreated(n.id, n.setting);
		updateRequired = true;
		return n;
	}

	public function createNodeByDataAt(x:Float, y:Float, data:NodeData):Node {
		var node = createNode(x, y, Node.deserializeType(data.type), NodeSetting.deserialize(data.setting));

		if (node.type.match(Module(_))) {
			node.moduleGraph = Graph.deserialize(data.graph, listener);
			node.moduleGraph.parent = this;
			node.moduleBoundaries = data.boundaries.map(index -> node.moduleGraph.nodes[index]);
		}

		for (s in data.sockets) {
			var type:SocketType = Socket.deserializeType(s.type, node.moduleBoundaries);
			var socket = node.createSocket(type);
			socket.phys.setAngle(s.angle);
		}
		updateRequired = true;
		return node;
	}

	public function insertNode(v:Vertex, n:Node):Bool {
		if (v.type != Normal)
			return false;
		var inputs:Array<Vertex> = [];
		var outputs:Array<Vertex> = [];
		for (e in v.edges) {
			if (v != e.v1) {
				inputs.push(e.v1);
			}
			if (v != e.v2) {
				outputs.push(e.v2);
			}
		}
		destroyVertex(v);
		for (v in inputs) {
			v.vibrate(true);
			var s = n.createSocket(Normal(I));
			s.phys.lookAt(v.point.x, v.point.y);
			createEdge(v, s.phys.vertex);
		}
		for (v in outputs) {
			v.vibrate(true);
			var s = n.createSocket(Normal(O));
			s.phys.lookAt(v.point.x, v.point.y);
			createEdge(s.phys.vertex, v);
		}
		return true;
	}

	public function createModule(nodesToContain:Array<Node>):Node {
		var boundaries = [];
		var cableEdges = [];
		isolateNodesAndCutCables(nodesToContain, boundaries, cableEdges);
		return createModuleAndConnectCables(nodesToContain, boundaries, cableEdges);
	}

	function isolateNodesAndCutCables(nodesToContain:Array<Node>, outBoundaries:Array<Node>, outCableEdges:Array<Vertex>):Void {
		var boundaryName:String = "A";
		for (n in nodesToContain) {
			for (s in n.sockets) {
				for (c in s.connections) {
					var s2 = c.other(s);
					var n2 = s2.parent;
					if (nodesToContain.indexOf(n2) == -1) { // connection to outside
						var s1p = s.phys;
						var s2p = s2.phys;
						var v1 = s1p.vertex;
						var v2 = s2p.vertex;
						var n1v = n.phys.vertex;
						var n2v = n2.phys.vertex;

						var ratio = 0.9;
						var boundaryX = v1.point.x + (v2.point.x - v1.point.x) * ratio;
						var boundaryY = v1.point.y + (v2.point.y - v1.point.y) * ratio;
						var boundaryNode = createNode(boundaryX, boundaryY, Boundary(s2.type.io()), new NodeSetting(boundaryName, Dupl));

						outBoundaries.push(boundaryNode);
						boundaryName = String.fromCharCode(boundaryName.charCodeAt(0) + 1);

						var boundarySocketPhys = boundaryNode.createSocket(Normal(s2.type.io())).phys;
						boundarySocketPhys.lookAt(n1v.point.x, n1v.point.y);

						// cut cable at socket2's side
						var edgeToCut = c.nearestEdge(s2);
						var cutCableSocket1Side = edgeToCut.other(s2p.vertex);
						var cutCableSocket2Side = v2;
						destroyEdge(edgeToCut);
						outCableEdges.push(cutCableSocket2Side);

						// connect socket1's side to the boundary node
						switch (s.type.io()) {
							case I:
								createEdge(boundarySocketPhys.vertex, cutCableSocket1Side);
							case O:
								createEdge(cutCableSocket1Side, boundarySocketPhys.vertex);
						}
					}
				}
			}
		}
	}

	function createModuleAndConnectCables(nodesToContain:Array<Node>, boundaries:Array<Node>, cables:Array<Vertex>):Node {
		if (nodesToContain.length == 0)
			return null;
		var meanX = 0.0;
		var meanY = 0.0;
		for (n in nodesToContain) {
			meanX += n.phys.vertex.point.x;
			meanY += n.phys.vertex.point.y;
		}
		meanX /= nodesToContain.length;
		meanY /= nodesToContain.length;

		var module = createNode(meanX, meanY, Module(false, false), new NodeSetting("mod", None));
		module.moduleBoundaries = boundaries;

		updateConnections(); // must update connections before transfer
		transferModule(nodesToContain.concat(boundaries), module.moduleGraph);

		for (i in 0...boundaries.length) {
			var boundary = boundaries[i];
			var name = boundary.setting.name;
			var cable = cables[i];
			switch (boundary.type) {
				case Boundary(io):
					var socketIO = !io;
					var sp = module.createSocket(name == "" ? Normal(socketIO) : Module(socketIO, boundary)).phys;
					sp.lookAt(cable.point.x, cable.point.y);

					switch (socketIO) {
						case I:
							connectCable(cable, sp.vertex);
						case O:
							connectCable(sp.vertex, cable);
					}
				case _:
					throw "not a boundary node";
			}
		}

		// centering
		var bv = module.moduleGraph.computeBoundingVolume();
		for (v in module.moduleGraph.vertices) {
			v.point.x -= bv.x;
			v.point.y -= bv.y;
		}

		return module;
	}

	function transferModule(ns:Array<Node>, to:Graph):Void {
		if (this == to)
			throw "cannot tranfer";
		dfs(null, null, true); // reset dfs count

		var vs:Array<Vertex> = [];
		var es:Map<Edge, Bool> = new Map();
		for (n in ns) {
			dfs(v -> {
				vs.push(v);
				for (e in v.edges) {
					es[e] = true; // collect all edges connected
				}
				return true;
			}, n.phys.vertex, false);
		}
		var ok = true;
		for (v in vs) {
			ok = ok && world.removePoint(v.point);
			to.world.addPoint(v.point);
			ok = ok && vertices.remove(v);
			to.vertices.push(v);
		}
		for (e in es.keys()) {
			ok = ok && world.removeSpring(e.spring);
			to.world.addSpring(e.spring);
			ok = ok && edges.remove(e);
			to.edges.push(e);
		}
		for (n in ns) {
			ok = ok && nodes.remove(n);
			to.nodes.push(n);
			n.g = to;
			for (s in n.sockets) {
				s.g = to;
			}
		}
		if (!ok) {
			throw "transfer failed";
		}
		updateRequired = true;
		to.updateRequired = true;
	}

	public function computeBoundingVolume():GraphBoundingVolume {
		if (nodes.length == 0)
			return new GraphBoundingVolume(0, 0, 1);
		var x = 0.0;
		var y = 0.0;
		var denom = 0.0;
		for (n in nodes) {
			if (n.type.match(Boundary(_)))
				continue;
			var p = n.phys.vertex.point;
			x += p.x;
			y += p.y;
			denom++;
		}
		var invV = 1 / (denom == 0 ? 1 : denom);
		x *= invV;
		y *= invV;
		var r = 0.0;
		for (n in nodes) {
			if (n.type.match(Boundary(_)))
				continue;
			var p = n.phys.vertex.point;
			var dx = x - p.x;
			var dy = y - p.y;
			var r2 = dx * dx + dy * dy;
			if (r2 > r * r) {
				r = Math.sqrt(r2);
			}
		}
		return new GraphBoundingVolume(x, y, r);
	}

	public function copyNode(n:Node):Node {
		var np = n.phys;
		var n2 = createNode(np.vertex.point.x, np.vertex.point.y, n.type, new NodeSetting(n.setting.name, n.setting.role.copy()));
		n2.phys.vertex.point.x = np.vertex.point.x;
		n2.phys.vertex.point.y = np.vertex.point.y;

		// we need to carefully copy the entire graph
		if (n.type.match(Module(_))) {
			var g1 = n.moduleGraph;
			var g2 = n2.moduleGraph;
			// copy nodes and sockets
			for (n1 in g1.nodes) {
				g2.copyNode(n1);
			}
			// copy connections
			for (i in 0...g1.nodes.length) {
				var n1 = g1.nodes[i];
				var n2 = g2.nodes[i];
				for (j in 0...n1.sockets.length) {
					var s1 = n1.sockets[j];
					var s2 = n2.sockets[j];
					if (s1.type.io() != O)
						continue;
					for (conn in s1.connections) {
						var from2 = s2;
						var to1 = conn.to;
						// get the socket at the same position
						var to2 = g2.nodes[g1.nodes.indexOf(to1.parent)].sockets[to1.parent.sockets.indexOf(to1)];
						g2.createEdge(from2.phys.vertex, to2.phys.vertex);
					}
				}
			}
			g2.updateConnections();
			n2.moduleBoundaries = n.moduleBoundaries.map(mb -> g2.nodes[g1.nodes.indexOf(mb)]);
		}

		for (s in n.sockets) {
			var type:SocketType = switch (s.type) {
				case Module(io, boundary):
					Module(io, n2.moduleBoundaries[n.moduleBoundaries.indexOf(boundary)]);
				case _:
					s.type;
			}
			var s2 = n2.createSocket(type);
			s.phys.computeDrawingPos();
			s2.phys.setNormal(s.phys.normalX, s.phys.normalY);
		}

		return n2;
	}

	public function decomposeModule(node:Node):Void {
		var g = node.moduleGraph;
		var bv = g.computeBoundingVolume();
		var np = node.phys;

		// shift vertices
		for (v in g.vertices) {
			v.point.x -= bv.x;
			v.point.y -= bv.y;
			v.point.x *= 0.5;
			v.point.y *= 0.5;
			v.point.x += np.vertex.point.x;
			v.point.y += np.vertex.point.y;
		}

		g.transferModule(g.nodes.copy(), this);

		// normalize sockets
		for (n in nodes) {
			for (s in n.sockets) {
				s.phys.lookAt(s.phys.vertex.point.x, s.phys.vertex.point.y);
			}
		}

		var boundaries = node.moduleBoundaries;
		var edgesIn = [for (_ in boundaries) []];
		var edgesOut = [for (_ in boundaries) []];
		for (s in node.sockets) {
			var sp = s.phys;
			var parent = switch (s.type) {
				case Module(_, boundary): boundary;
				case _: throw "not a module socket";
			};
			var index = boundaries.indexOf(parent);
			var edges = sp.vertex.edges.copy();
			for (e in edges) {
				if (e == sp.edge)
					continue;
				switch (s.type.io()) {
					case I:
						edgesIn[index].push(e.other(sp.vertex));
					case O:
						edgesOut[index].push(e.other(sp.vertex));
				}
				destroyEdge(e);
			}
		}
		for (i in 0...boundaries.length) {
			var b = boundaries[i];
			b.boundaryToNormal();
			for (v in edgesIn[i]) {
				var s = b.createSocket(Normal(I));
				s.phys.lookAt(v.point.x, v.point.y);
				createEdge(v, s.phys.vertex);
			}
			for (v in edgesOut[i]) {
				var s = b.createSocket(Normal(O));
				s.phys.lookAt(v.point.x, v.point.y);
				createEdge(s.phys.vertex, v);
			}
		}
		destroyNode(node);
	}

	public function destroyNode(n:Node):Void {
		var sockets = n.sockets.copy();
		for (s in sockets) {
			n.destroySocket(s);
		}

		switch (n.type) {
			case Module(_):
				n.moduleGraph.destroyEverything();
			case _:
				listener.onNodeDestroyed(n.id);
		}

		destroyVertexUnsafe(n.phys.vertex);
		nodes.remove(n);
		updateRequired = true;
	}

	public function destroyEverything():Void {
		var ns = nodes.copy();
		for (n in ns) {
			destroyNode(n);
		}
		var es = edges.copy();
		for (e in es) {
			destroyEdge(e);
		}
		var vs = vertices.copy();
		for (v in vs) {
			destroyVertex(v);
		}
	}

	public function connectCable(from:Vertex, to:Vertex):Void {
		var dx:Float = to.point.x - from.point.x;
		var dy:Float = to.point.y - from.point.y;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		var invDist = dist == 0 ? 0 : 1 / dist;
		var nx:Float = dx * invDist;
		var ny:Float = dy * invDist;
		var interval = CABLE_LENGTH + 1.0;
		var extended:Array<Vertex> = [];
		while (dist > interval) {
			var x:Float = from.point.x + nx * interval;
			var y:Float = from.point.y + ny * interval;
			var mid:Vertex = createVertex(x, y, Normal, CABLE_MASS);
			extended.push(mid);
			createEdge(from, mid);
			dist -= interval;
			from = mid;
		}
		for (v in extended)
			v.vibrate();
		createEdge(from, to);
	}

	public function isConnectable(from:Vertex, to:Vertex):Bool {
		if (from == to || !isOutput(from) || !isInput(to) || isInSameCable(from, to))
			return false;
		return true;
	}

	public function connectVertices(from:Vertex, to:Vertex):Bool {
		if (!isConnectable(from, to))
			return false;
		var dx:Float = to.point.x - from.point.x;
		var dy:Float = to.point.y - from.point.y;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		if (dist == 0) {
			dx = 0.1;
			dist = dx * dx;
		}
		var invDist = 1 / dist;
		var nx:Float = dx * invDist;
		var ny:Float = dy * invDist;

		switch (from.type) {
			case Node(n):
				var sp = n.createSocket(Normal(O)).phys;
				sp.setNormal(nx, ny);
				from = sp.vertex;
			case _:
		}
		switch (to.type) {
			case Node(n):
				var sp = n.createSocket(Normal(I)).phys;
				sp.setNormal(-nx, -ny);
				to = sp.vertex;
			case _:
		}

		connectCable(from, to);
		return true;
	}

	function isOutput(v:Vertex):Bool {
		return switch (v.type) {
			case Node(n):
				switch (n.type) {
					case Normal(_, output): output;
					case Module(_, output): output;
					case Small: true;
					case Boundary(io): io == O;
				}
			case Socket(s):
				switch (s.type.io()) {
					case I: false;
					case O: true;
				}
			case Normal: true;
		}
	}

	function isInput(v:Vertex):Bool {
		return switch (v.type) {
			case Node(n):
				switch (n.type) {
					case Normal(input, _): input;
					case Module(input, _): input;
					case Small: true;
					case Boundary(io): io == I;
				}
			case Socket(s):
				switch (s.type.io()) {
					case I: true;
					case O: false;
				}
			case Normal: true;
		}
	}

	public inline function hasVisitedInDfs(v:Vertex):Bool {
		return v.tmpValForDfs == dfsCount;
	}

	public function dfs(onVisit:Vertex->Bool, from:Vertex, updateDfsCount:Bool = true):Void {
		if (updateDfsCount)
			dfsCount++;
		if (onVisit == null || from == null || from.tmpValForDfs == dfsCount)
			return;
		var vs:Array<Vertex> = [];
		vs.push(from);
		while (vs.length > 0) {
			var v = vs.pop();
			v.tmpValForDfs = dfsCount;
			if (!onVisit(v))
				continue;
			for (e in v.edges) {
				if (e.v1.tmpValForDfs != dfsCount) {
					e.v1.tmpValForDfs = dfsCount;
					vs.push(e.v1);
				}
				if (e.v2.tmpValForDfs != dfsCount) {
					e.v2.tmpValForDfs = dfsCount;
					vs.push(e.v2);
				}
			}
		}
	}

	function isInSameCable(v1:Vertex, v2:Vertex):Bool {
		var result = false;
		dfs(v -> {
			if (v == v2)
				result = true;
			return !result && v.type == Normal;
		}, v1);
		return result;
	}

	public function createVertex(x:Float, y:Float, type:VertexType, invM:Float):Vertex {
		var v:Vertex = new Vertex(x, y, type, invM);
		world.addPoint(v.point);
		vertices.push(v);
		updateRequired = true;
		return v;
	}

	public function createEdge(outVertex:Vertex, inVertex:Vertex, length:Float = 0):Edge {
		var stiff = outVertex.type.match(Node(_)) || inVertex.type.match(Node(_));
		var e:Edge = new Edge(outVertex, inVertex, length, stiff);
		world.addSpring(e.spring);
		e.connect();
		edges.push(e);
		updateRequired = true;

		{
			var v = outVertex;
			if (v.type == Normal && v.edges.length > 2) {
				throw "!?!?!?";
			}
		} {
			var v = inVertex;
			if (v.type == Normal && v.edges.length > 2) {
				throw "!?!?!?";
			}
		}

		return e;
	}

	public function updateConnections():Void {
		updateRequired = false;
		trace("computing connections");

		for (e in edges) {
			e.firstEdgeOf = null;
			e.lastEdgeOf = null;
		}

		for (n in nodes) {
			for (s in n.sockets) {
				s.prevConnections = s.connections;
				s.connections = []; // clear connections
			}
		}

		for (n in nodes) {
			for (s in n.sockets) {
				// only check output sockets to avoid duplications
				if (s.type.io() != O)
					continue;
				var sp = s.phys;
				var edgeBackToNode = sp.edge;
				// follow cables from the socket
				for (e in sp.vertex.edges) {
					if (e == edgeBackToNode)
						continue;
					var prevV = sp.vertex;
					var v = e.other(prevV);
					var firstEdge = e;
					var lastEdge = e;
					var info = new CableInfo();
					while (v != null && v.type == Normal) {
						v.followCable(prevV, info);
						prevV = v;
						v = info.vertex;
						lastEdge = info.edge;
					}
					if (v == null)
						continue;
					switch (v.type) {
						case Socket(s2):
							if (s2.type.io() != I)
								throw "socket type error";
							for (c in s.connections)
								if (c.from == s && c.to == s2)
									throw "duplicate connection found";
							var conn = new SocketConnection(s, s2, firstEdge, lastEdge);
							firstEdge.firstEdgeOf = conn;
							lastEdge.lastEdgeOf = conn;
							s.connections.push(conn);
							s2.connections.push(conn);
						case _:
							throw "cable connected to invalid vertex";
					}
				}
			}
		}

		var newConnections:Array<Int> = [];

		// add new connections and remove updated old connections
		for (n in nodes) {
			for (s in n.sockets) {
				if (s.type.io() != O)
					continue;
				for (c in s.connections) {
					var s2 = c.to;
					var oldIndex = SocketConnection.indexOf(s.prevConnections, s, s2);
					if (oldIndex == -1) {
						// add new connection
						newConnections.push(s.id);
						newConnections.push(s2.id);
					} else {
						s.prevConnections.splice(oldIndex, 1);
					}
				}
			}
		}
		// remove obsoleted connections
		for (n in nodes) {
			for (s in n.sockets) {
				if (s.type.io() != O)
					continue;
				for (c in s.prevConnections) {
					var s2 = c.to;
					// remove old connection
					listener.onSocketDisconnected(s.id, s2.id);
				}
			}
		}
		// notify new connections
		for (i in 0...newConnections.length >> 1) {
			listener.onSocketConnected(newConnections[i << 1], newConnections[i << 1 | 1]);
		}
		// notify updates
		for (n in nodes) {
			n.notifyUpdate();
		}
	}

	public function stepPhysics():Void {
		// split edges
		{
			var i = -1;
			while (++i < edges.length) {
				var e:Edge = edges[i];
				if (!e.spring.stiff && e.spring.prevDist > CABLE_LENGTH * 1.05) {
					var v1 = e.v1;
					var v2 = e.v2;
					var x1 = v1.point.x;
					var y1 = v1.point.y;
					var x2 = v2.point.x;
					var y2 = v2.point.y;
					var tmp = updateRequired;
					var v3 = createVertex((x1 + x2) * 0.5, (y1 + y2) * 0.5, Normal, 1 / CABLE_MASS);
					var c1 = e.firstEdgeOf;
					var c2 = e.lastEdgeOf;
					destroyEdge(e);
					var e1 = createEdge(v1, v3);
					var e2 = createEdge(v3, v2);
					if (c1 != null) {
						c1.firstEdge = e1;
						e1.firstEdgeOf = c1;
					}
					if (c2 != null) {
						c2.lastEdge = e2;
						e2.lastEdgeOf = c2;
					}
					updateRequired = tmp; // this does not change topology
					i--;
				}
			}
		}

		// merge edges
		{
			var i = -1;
			while (++i < vertices.length) {
				var v:Vertex = vertices[i];
				if (!v.type.match(Normal))
					continue;
				if (v.edges.length == 0) {
					destroyVertex(v);
					i--;
					continue;
				}
				if (v.edges.length == 1) {
					var e = v.edges[0];
					var other = e.v1 == v ? e.v2 : e.v1;
					if (--v.life <= 0 || other.edges.length != 2 || other.type != Normal) {
						destroyVertex(v);
						i--;
						continue;
					}
				}
				if (v.edges.length != 2)
					continue;
				var e1 = v.edges[0];
				var e2 = v.edges[1];
				if (e1.spring.stiff || e2.spring.stiff)
					continue;
				if (v == e1.v2 && v == e2.v1) {
					// e1.v1 -> v -> e2.v2, do nothhng
				} else if (v == e2.v2 && v == e1.v1) {
					// e2.v1 -> v -> e1.v2, swap them
					var tmp = e1;
					e1 = e2;
					e2 = tmp;
				} else {
					continue;
				}
				var v1 = e1.v1;
				var v2 = e2.v2;
				var c1 = e1.firstEdgeOf;
				var c2 = e2.lastEdgeOf;
				if ((!v1.type.match(Normal) || v1.edges.length > 2) && (!v2.type.match(Normal) || v2.edges.length > 2))
					continue;
				var s1 = e1.spring.prevDist;
				var s2 = e2.spring.prevDist;
				if (s1 + s2 > CABLE_LENGTH * 0.95)
					continue;
				var tmp = updateRequired;
				destroyVertex(v);
				var e = createEdge(v1, v2);
				if (c1 != null) {
					c1.firstEdge = e;
					e.firstEdgeOf = c1;
				}
				if (c2 != null) {
					c2.lastEdge = e;
					e.lastEdgeOf = c2;
				}
				updateRequired = tmp; // this does not change topology
				i--;
			}
		}

		// remove empty sockets
		{
			for (n in nodes) {
				var toDestroy:Array<Socket> = null;
				for (s in n.sockets) {
					if (!s.type.match(Normal(_)))
						continue;
					if (s.phys.vertex.edges.length == 1) {
						if (toDestroy == null)
							toDestroy = [];
						toDestroy.push(s);
					}
				}
				if (toDestroy != null) {
					for (s in toDestroy) {
						n.destroySocket(s);
					}
				}
			}
		}

		// remove unnecessary nodes
		{
			inline function connectedVertex(sp:SocketPhys):Vertex {
				var res:Vertex = null;
				for (e in sp.vertex.edges) {
					var v = e.other(sp.vertex);
					if (!v.type.match(Node(_))) {
						res = v;
						break;
					}
				}
				return res;
			}

			var i:Int = -1;
			while (++i < nodes.length) {
				var n = nodes[i];
				if (n.type != Small)
					continue;
				var ins:Int = 0;
				var outs:Int = 0;
				var inV:Vertex = null;
				var outV:Vertex = null;
				for (s in n.sockets) {
					switch (s.type.io()) {
						case I:
							ins++;
							inV = connectedVertex(s.phys);
						case O:
							outs++;
							outV = connectedVertex(s.phys);
					}
				}
				if (ins <= 1 && outs <= 1) {
					destroyNode(n);
					if (inV != null && outV != null)
						createEdge(inV, outV);
					if (inV != null)
						inV.vibrate(true);
					if (outV != null)
						outV.vibrate(true);
					i--;
					continue;
				}
			}
		}

		// update connections
		if (updateRequired) {
			updateConnections();
		}

		// update drawing pos
		for (n in nodes) {
			for (s in n.sockets) {
				s.phys.computeDrawingPos();
			}
		}

		// node-node | socket-socket
		for (i in 1...nodes.length) {
			for (j in 0...i) {
				var n1 = nodes[i];
				var n2 = nodes[j];
				var n1p = n1.phys;
				var n2p = n2.phys;

				collide(n1p.vertex, n2p.vertex, n1p.radius + n2p.radius + MARGIN);
				for (s1 in n1.sockets) {
					for (s2 in n2.sockets) {
						var s1p = s1.phys;
						var s2p = s2.phys;
						collide(s1p.vertex, s2p.vertex, s1p.radius + s2p.radius + MARGIN);
					}
				}
			}
		}
		// node-socket
		for (n1 in nodes) {
			for (n2 in nodes) {
				for (s2 in n2.sockets) {
					var n1p = n1.phys;
					var s2p = s2.phys;
					collide(n1p.vertex, s2p.vertex, n1p.radius + s2p.radius + MARGIN);
				}
			}
		}
		// socket-socket in node
		for (n in nodes) {
			for (i in 1...n.sockets.length) {
				for (j in 0...i) {
					var s1 = n.sockets[i];
					var s2 = n.sockets[j];
					var s1p = s1.phys;
					var s2p = s2.phys;

					var strength = s1.type.match(Param(_)) || s2.type.match(Param(_)) ? 1 : 0.2;
					collide(s1p.vertex, s2p.vertex, s1p.radius + s2p.radius + MARGIN, strength);
				}
			}
		}
		for (v in vertices) {
			if (v.type != Normal)
				continue;
			// cable-node
			for (n in nodes) {
				var np = n.phys;
				collide(v, np.vertex, np.radius + MARGIN);
			}
			// cable branch
			var n:Int = v.edges.length;

			if (n <= 2)
				continue;
			inline function other(e:Edge):Vertex {
				return e.v1 != v ? e.v1 : e.v2;
			}

			for (i in 1...n) {
				for (j in 0...i) {
					var v1:Vertex = other(v.edges[i]);
					var v2:Vertex = other(v.edges[j]);
					collide(v1, v2, 1.5 * CABLE_LENGTH);
				}
			}
		}
		world.step();
	}

	extern inline function collide(v1:Vertex, v2:Vertex, r:Float, strength:Float = 1.0):Void {
		var invM1:Float = v1.point.invM;
		var invM2:Float = v2.point.invM;
		if (invM1 + invM2 == 0) {
			invM1 = 1;
			invM2 = 1;
		}
		var x1:Float;
		var y1:Float;
		var x2:Float;
		var y2:Float;
		switch (v1.type) {
			case Socket(s):
				x1 = s.phys.xForDrawing;
				y1 = s.phys.yForDrawing;
			case _:
				x1 = v1.point.x;
				y1 = v1.point.y;
		}
		switch (v2.type) {
			case Socket(s):
				x2 = s.phys.xForDrawing;
				y2 = s.phys.yForDrawing;
			case _:
				x2 = v2.point.x;
				y2 = v2.point.y;
		}
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		var invDist:Float = dist == 0 ? 0 : 1 / dist;
		var nx:Float = dx * invDist;
		var ny:Float = dy * invDist;
		var f:Float = (r - dist) * strength;
		f /= invM1 + invM2;
		f *= 0.1;
		if (f > 0) {
			v1.point.vx += f * nx * invM1;
			v1.point.vy += f * ny * invM1;
			v2.point.vx -= f * nx * invM2;
			v2.point.vy -= f * ny * invM2;
		}
	}

	public function pick(x:Float, y:Float, flags:PickFlag, radius:Float):Vertex {
		var minD:Float = radius;
		var minV:Vertex = null;
		for (v in vertices) {
			var vx:Float = v.point.x;
			var vy:Float = v.point.y;
			var r:Float = 0;
			switch (v.type) {
				case Node(n):
					if (flags & PickFlag.Node == 0)
						continue;
					r = n.phys.radius;
				case Socket(s):
					if ((flags & switch (s.type) {
						case Normal(I): PickFlag.Input;
						case Normal(O): PickFlag.Output;
						case Param(I, _) | Module(I, _): PickFlag.InputParam;
						case Param(O, _) | Module(O, _): PickFlag.OutputParam;
					}) == 0)
						continue;
					var sp = s.phys;
					sp.computeDrawingPos();
					vx = sp.xForDrawing;
					vy = sp.yForDrawing;
					r = sp.radius;
				case Normal:
					if (flags & PickFlag.Cable == 0)
						continue;
					r = CABLE_LENGTH * 0.5;
			}
			var dx:Float = x - vx;
			var dy:Float = y - vy;
			var dist:Float = Math.sqrt(dx * dx + dy * dy);
			dist -= r;
			if (dist < minD) {
				minD = dist;
				minV = v;
			}
		}
		return minV;
	}

	public function destroyVertex(v:Vertex):Void {
		switch (v.type) {
			case Node(_):
				throw "cannot destroy node vertex";
			case Socket(_):
				throw "cannot destroy socket vertex";
			case Normal:
				destroyVertexUnsafe(v);
		}
	}

	public function destroyVertexUnsafe(v:Vertex):Void {
		var es = v.edges.copy();
		for (e in es) {
			destroyEdge(e);
		}
		world.removePoint(v.point);
		if (!vertices.remove(v))
			throw "couldn't remove vertex";
		updateRequired = true;
	}

	function destroyEdge(e:Edge):Void {
		world.removeSpring(e.spring);
		e.disconnect();
		if (!edges.remove(e))
			throw "couldn't remove edge";
		updateRequired = true;
	}

	public function serialize():GraphData {
		updateConnections();
		var nodes:Array<NodeData> = [];
		for (n in this.nodes) {
			nodes.push(n.serialize());
		}
		var connections:Array<SocketConnectionData> = [];
		for (n in this.nodes) {
			for (s in n.sockets) {
				if (s.type.io() == I)
					continue;
				for (c in s.connections) {
					var fromN = c.from.parent;
					var toN = c.to.parent;
					connections.push({
						n1: this.nodes.indexOf(fromN),
						s1: fromN.sockets.indexOf(c.from),
						n2: this.nodes.indexOf(toN),
						s2: toN.sockets.indexOf(c.to)
					});
				}
			}
		}
		return {
			nodes: nodes,
			connections: connections
		}
	}

	public static function deserialize(data:GraphData, listener:GraphListener):Graph {
		var g = new Graph(listener);
		for (n in data.nodes) {
			var node = g.createNode(n.x, n.y, Node.deserializeType(n.type), NodeSetting.deserialize(n.setting));

			if (node.type.match(Module(_))) {
				node.moduleGraph = Graph.deserialize(n.graph, listener);
				node.moduleGraph.parent = g;
				node.moduleBoundaries = n.boundaries.map(index -> node.moduleGraph.nodes[index]);
			}

			for (s in n.sockets) {
				var type:SocketType = Socket.deserializeType(s.type, node.moduleBoundaries);
				var socket = node.createSocket(type);
				socket.phys.setAngle(s.angle);
			}
		}
		for (c in data.connections) {
			var s1 = g.nodes[c.n1].sockets[c.s1];
			var s2 = g.nodes[c.n2].sockets[c.s2];
			g.connectCable(s1.phys.vertex, s2.phys.vertex);
		}
		g.updateConnections();
		return g;
	}
}
