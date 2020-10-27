package app.ui.view.main.graph;

import app.ui.view.menu.dialogue.EditNameDialogue.EditNameDialog;
import app.ui.view.main.graph.history.GraphHistory;
import app.ui.view.main.graph.history.GraphOperation;
import app.ui.view.main.graph.history.HistoryPoint;
import app.ui.view.menu.nodeedit.NodeEditMenu;
import common.Set;
import graph.Edge;
import graph.Graph;
import graph.Node;
import graph.PickFlag;
import graph.Socket;
import graph.Vertex;
import graph.serial.NodeFilter;
import render.View;
import render.ViewData;

class GraphWrapper {
	public var raw(default, null):Graph;
	public final view:View;
	public final selection:Selection;
	public final socketSelection:Set<Socket>;
	public final trail:Trail;
	public final connectableChecker:ConnectableChecker;
	public var nodes(get, never):Array<Node>;
	public var vertices(get, never):Array<Vertex>;
	public var edges(get, never):Array<Edge>;
	public var lastOperation(default, null):GraphOperation;

	public final nodeShadows:Array<NodeShadow> = [];
	public final connectionShadows:Array<ConnectionShadow> = [];

	final viewDataMap:Map<Int, ViewData> = [];
	final history:GraphHistory;

	public final op:MainOperator;

	public function new(graph:Graph, view:View, op:MainOperator) {
		this.view = view;
		this.op = op;
		raw = graph;
		selection = new Selection(this);
		socketSelection = new Set<Socket>();
		trail = new Trail();
		connectableChecker = new ConnectableChecker(this);
		history = new GraphHistory();
	}

	public function interact(n:Node):Void {
		if (n.type.match(Boundary(_))) {
			// open edit dialogue directly
			op.openMenu(NodeEditMenu.createNameEditDialogue(this, n, doneOperation.bind(NodeEdit)));
			return;
		}
		switch n.setting.role {
			case Frequency | Oscillator(_) | Delay | Filter(_) | Compressor | Envelope(_) | Number(_) | None:
				op.openMenu(new NodeEditMenu(n, this));
			case BinOp(type):
				switch type {
					case Add:
						n.setting.role = BinOp(Mult);
						n.setting.name = "×";
					case Mult:
						n.setting.role = BinOp(Add);
						n.setting.name = "+";
				}
				n.notifyUpdate();
			case Dupl | Destination: // do nothing
		}
	}

	@:allow(app.ui.view.main.MainSprite)
	function gotoGraph(graph:Graph):Void {
		selection.clear();
		saveView();
		this.raw = graph;
		loadView();
	}

	public inline function undo():Void {
		loadSnapshot(history.undo());
	}

	public inline function redo():Void {
		loadSnapshot(history.redo());
	}

	public inline function canUndo():Bool {
		return history.canUndo();
	}

	public inline function canRedo():Bool {
		return history.canRedo();
	}

	public function addUndoPoint():Void {
		history.addSnapshot(takeSnapshot());
		trace("snapshot added.");
	}

	function takeSnapshot():HistoryPoint {
		var data = raw.getRoot().serialize(NodeFilter.ALL, true);
		var atGraphId = raw.id;
		return new HistoryPoint(data, atGraphId);
	}

	function loadSnapshot(snapshot:HistoryPoint):Void {
		op.loadAsRoot(snapshot.data, false);
		var location = Graph.searchGraphById(raw, snapshot.atGraphId);
		if (location == null)
			throw "cannot find graph by id: " + snapshot.atGraphId;
		op.gotoGraph(location);
	}

	public function saveView():Void {
		viewDataMap[raw.id] = view.getData();
	}

	public function loadView():Void {
		var data = viewDataMap[raw.id];
		if (data == null)
			data = new ViewData();
		view.setData(data);
	}

	public function addNodeShadow(ns:NodeShadow):Void {
		nodeShadows.push(ns);
	}

	public function clearNodeShadows():Void {
		nodeShadows.resize(0);
	}

	public function addConnectionShadow(cs:ConnectionShadow):Void {
		connectionShadows.push(cs);
	}

	public function clearConnectionShadows():Void {
		connectionShadows.resize(0);
	}

	public function pickWithCurrentScale(x:Float, y:Float, flag:PickFlag):Vertex {
		return raw.pick(x, y, flag, ClickSettings.PICK_RADIUS_PX / view.scale);
	}

	public function relation(v1:Vertex, v2:Vertex, flipped:Bool = false):VertexRelation {
		var lowLevelCheck:VertexRelation = (flipped ? raw.isConnectable(v2, v1) : raw.isConnectable(v1, v2)) ? Connectable : Unconnectable;
		switch v1.type {
			case Node(n1):
				switch v2.type {
					case Node(n2):
						if (n1 == n2)
							return Same;
						// check if normal-normal connections exist
						for (s in n1.sockets) {
							if (s.type.match(Normal(_))) {
								for (c in s.connections) {
									if (c.other(s).type.match(Normal(_))) {
										if (n2.sockets.indexOf(c.other(s)) != -1)
											return Unconnectable;
									}
								}
							}
						}
						return lowLevelCheck;
					case Socket(s2):
						if (s2.type.match(Normal(_)))
							return Unconnectable; // cannot directly connect to normal socket
						if (n1.sockets.indexOf(s2) != -1)
							return Same;
						// check if normal-socket connections exist
						for (s in n1.sockets) {
							if (s.type.match(Normal(_))) {
								for (c in s.connections) {
									if (c.other(s) == s2)
										return Unconnectable;
								}
							}
						}
						return lowLevelCheck;
					case Normal:
						for (s in n1.sockets) {
							if (raw.isOnCableFrom(v2, s.phys.vertex))
								return Same;
						}
						return lowLevelCheck;
				}
			case Socket(s1):
				if (s1.type.match(Normal(_)))
					return Unconnectable; // cannot directly connect from normal socket
				return switch v2.type {
					case Node(_):
						relation(v2, v1, true);
					case Socket(s2):
						if (s1.type.match(Normal(_)))
							return Unconnectable; // cannot directly connect to normal socket
						s1.parent == s2.parent ? Same : lowLevelCheck;
					case Normal:
						raw.isOnCableFrom(v2, v1) ? Same : lowLevelCheck;
				}
			case Normal:
				return switch v2.type {
					case Node(_) | Socket(_):
						relation(v2, v1, true);
					case Normal:
						raw.isOnCableFrom(v1, v2) ? Same : lowLevelCheck;
				}
		}
	}

	public function createModuleWithCurrentSelection():Bool {
		var nodes = [];
		var ng = false;
		selection.forEach(n -> {
			if (n.setting.role == Destination) {
				op.showInfo("Cannot include the output node.", Warning);
				ng = true;
				return;
			}
			if (n.type.match(Boundary(_))) {
				op.showInfo("Cannot include boundary nodes.", Warning);
				ng = true;
				return;
			}
			nodes.push(n);
		});
		if (ng)
			return false;
		if (nodes.length < 2) {
			op.showInfo("Select two or more nodes.", Warning);
			return false;
		}
		raw.createModule(nodes);
		return true;
	}

	public function decomposeModules(modules:Array<Node>):Void {
		for (n in modules) {
			raw.decomposeModule(n);
		}
	}

	public function moveNodes(nodes:Array<Node>, dx:Float, dy:Float):Void {
		for (node in nodes) {
			var p = node.phys.vertex.point;
			p.x += dx;
			p.y += dy;
			for (s in node.sockets) {
				s.phys.vertex.point.x += dx;
				s.phys.vertex.point.y += dy;
				if (s.type.io() != O) // avoid duplicate checks
					continue;
				for (conn in s.connections) {
					if (nodes.contains(conn.to.parent)) {
						// move vertices between the sockets
						for (v in conn.getIntermediateVertices()) {
							v.point.vx = 0;
							v.point.vy = 0;
							v.point.x += dx * 0.75;
							v.point.y += dy * 0.75;
						}
					}
				}
			}
		}
	}

	public function doneOperation(op:GraphOperation):Void {
		trace("operation done: " + op.getName());
		lastOperation = op;
		addUndoPoint();
	}

	public function canDestroyVertex(v:Vertex):Bool {
		return switch v.type {
			case Node(n):
				return isEditableNode(n);
			case Socket(_):
				false;
			case Normal:
				true;
		}
	}

	public function destroyVertices(vs:Array<Vertex>, vibrate:Bool):Bool {
		if (vs.length < 1)
			return false;
		for (v in vs) {
			if (!canDestroyVertex(v))
				throw "cannot destroy by vertex";
			if (vibrate)
				v.vibrate(true);
			switch v.type {
				case Node(n):
					raw.destroyNode(n);
					selection.remove(n);
				case Socket(_):
					throw "cannot destroy socket through this method";
				case Normal:
					raw.destroyVertex(v);
			}
		}
		return true;
	}

	public function isEditableNode(node:Node):Bool {
		if (node.setting.role.match(Destination))
			return false;
		return switch node.type {
			case Normal(_, _) | Module(_, _) | Small:
				true;
			case Boundary(_):
				false;
		}
	}

	public function canDestroyNode(node:Node):Bool {
		return isEditableNode(node);
	}

	public function destroyNodes(nodes:Array<Node>):Bool {
		if (nodes.length < 1)
			return false;
		for (n in nodes) {
			if (!isEditableNode(n))
				throw "cannot destroy the node through this method";
			raw.destroyNode(n);
		}
		return true;
	}

	public static function connectVerticesMakingSockets(g:Graph, src:Vertex, dst:Vertex):Void {
		var srcV = switch src.type {
			case Node(n1):
				var s1 = n1.createSocket(Normal(O));
				s1.phys.lookAt(dst.point.x, dst.point.y);
				s1.phys.vertex;
			case Socket(s1):
				s1.phys.vertex;
			case Normal:
				var n1 = NodeList.DUPL.create(g, src.point.x, src.point.y, false);
				g.insertNode(src, n1);
				var sp = n1.createSocket(Normal(O)).phys;
				sp.lookAt(dst.point.x, dst.point.y);
				sp.vertex;
		};
		var dstV = switch dst.type {
			case Node(n2):
				var s2 = n2.createSocket(Normal(I));
				s2.phys.lookAt(srcV.point.x, srcV.point.y);
				s2.phys.vertex;
			case Socket(s2):
				s2.phys.vertex;
			case Normal:
				var n2 = (switch src.type {
					case Node(n):
						switch n.setting.role {
							case Envelope(_) | Number(_):
								NodeList.MULT;
							case _:
								NodeList.ADD;
						}
					case _:
						NodeList.ADD;
				}).create(g, dst.point.x, dst.point.y, false);
				g.insertNode(dst, n2);
				var sp = n2.createSocket(Normal(I)).phys;
				sp.lookAt(srcV.point.x, srcV.point.y);
				sp.vertex;
		}
		g.connectVertices(srcV, dstV);
	}

	extern inline function get_nodes():Array<Node> {
		return raw.nodes;
	}

	extern inline function get_vertices():Array<Vertex> {
		return raw.vertices;
	}

	extern inline function get_edges():Array<Edge> {
		return raw.edges;
	}
}
