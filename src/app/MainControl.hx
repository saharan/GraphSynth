package app;

import graph.Node;
import graph.NodeSetting;
import graph.Vertex;

class MainControl extends Control {
	var cableFrom:Vertex;
	var dragging:Vertex;

	var pickRadius:Float;

	var beginCanvasX:Float;
	var beginCanvasY:Float;
	var beginCenterX:Float;
	var beginCenterY:Float;
	var panning:Bool;
	var panTargetX:Float;
	var panTargetY:Float;

	public function new(context:Context) {
		super(context);
		pickRadius = UISetting.tapErrorThreshold / renderer.view.scale;
		panTargetX = renderer.view.centerX;
		panTargetY = renderer.view.centerY;
	}

	public function centering():Void {
		panTargetX = 0;
		panTargetY = 0;
		var bv = graph.computeBoundingVolume();
		renderer.view.centerX -= bv.x;
		renderer.view.centerY -= bv.y;
		for (v in graph.vertices) {
			v.point.x -= bv.x;
			v.point.y -= bv.y;
		}
	}

	function makeNode(info:NodeInfo):Node {
		inline function rand():Float {
			return Math.random() * 2 - 1;
		}
		var n = graph.createNode(rand() * 10, 50 + rand() * 10, info.type, new NodeSetting(info.labelName, info.role));
		for (s in info.inParams) {
			n.createSocket(Param(I, s));
		}
		for (s in info.outParams) {
			n.createSocket(Param(O, s));
		}
		var np = n.phys;
		np.vertex.point.vx = Math.random() * 8 - 4;
		np.vertex.point.vy = Math.random() * 8 - 4;
		for (s in n.sockets) {
			var sp = s.phys;
			sp.vertex.point.vx = np.vertex.point.vx;
			sp.vertex.point.vy = np.vertex.point.vy;
		}
		return n;
	}

	override function onDragBegin(x:Float, y:Float, tapCount:Int) {
		if (tapCount == 1) {
			var v:Vertex = graph.pick(x, y, Connectable, pickRadius);
			dragging = v;
			if (dragging == null) {
				beginCanvasX = renderer.canvasX(x);
				beginCanvasY = renderer.canvasY(y);
				beginCenterX = panTargetX;
				beginCenterY = panTargetY;
				panning = true;
			}
			trace("drag");
		} else if (tapCount == 2) {
			var v:Vertex = graph.pick(x, y, All, pickRadius);
			cableFrom = v;
			trace("from " + (v != null));
		}
	}

	override function onPressing(x:Float, y:Float) {
		if (panning) {
			panTargetX = beginCenterX - (renderer.canvasX(x) - beginCanvasX) / renderer.view.scale;
			panTargetY = beginCenterY - (renderer.canvasY(y) - beginCanvasY) / renderer.view.scale;
		}
		if (dragging != null) {
			var dx:Float = x - dragging.point.x;
			var dy:Float = y - dragging.point.y;
			var dvx:Float = dx * 0.05;
			var dvy:Float = dy * 0.05;
			dragging.point.vx += dvx;
			dragging.point.vy += dvy;
			switch (dragging.type) {
				case Node(n):
					for (s in n.sockets) {
						var sp = s.phys;
						sp.vertex.point.vx += dvx;
						sp.vertex.point.vy += dvy;
					}
				case _:
			}
		}
	}

	override function onLongPress(x:Float, y:Float, tapCount:Int) {
		if (tapCount == 1) {
			var v:Vertex = graph.pick(x, y, Configurable, pickRadius);
			if (v == null) {
				nextControl = new MainMenuControl(context, x, y);
			}
			if (v != null) {
				switch (v.type) {
					case Node(n):
						switch (n.setting.role) {
							case BinOp(Add):
								n.setting.name = "×";
								n.setting.role = BinOp(Mult);
								n.notifyUpdate();
							case BinOp(Mult):
								n.setting.name = "+";
								n.setting.role = BinOp(Add);
								n.notifyUpdate();
							case Number(num):
								nextControl = NumberEditControl.createValueEdit(context, n, num);
							case _:
								nextControl = new NodeEditControl(context, n);
						}
					case _:
				}
			}
		}
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		dragging = null;
		panning = false;
		if (tapCount == 2) {
			var v:Vertex = graph.pick(x, y, Removable, pickRadius);
			if (v != null && v.type == Normal) {
				for (e in v.edges) {
					var v2 = e.other(v);
					if (v2.type == Normal)
						v2.vibrate(true);
				}
				graph.destroyVertex(v);
			}
			trace("destroy");
		}
		if (cableFrom != null) {
			trace("connect");
			var v:Vertex = graph.pick(x, y, Connectable, pickRadius);
			if (v != null && graph.isConnectable(cableFrom, v)) {
				if (cableFrom.type == Normal) {
					var node = makeNode(NodeList.DUPL);
					var np = node.phys;
					np.vertex.point.x = cableFrom.point.x;
					np.vertex.point.y = cableFrom.point.y;
					np.vertex.point.vx = 0;
					np.vertex.point.vy = 0;
					graph.insertNode(cableFrom, node);
					var sp = node.createSocket(Normal(O)).phys;
					sp.lookAt(v.point.x, v.point.y);
					cableFrom = sp.vertex;
				}
				if (v.type == Normal) {
					var node = makeNode((switch (cableFrom.type) {
						case Node(n): n.setting.role.match(Number(_) | Envelope(_));
						case _: false;
					}) ? NodeList.MULT : NodeList.ADD);
					var np = node.phys;
					np.vertex.point.x = v.point.x;
					np.vertex.point.y = v.point.y;
					np.vertex.point.vx = 0;
					np.vertex.point.vy = 0;
					graph.insertNode(v, node);
					var sp = node.createSocket(Normal(I)).phys;
					sp.lookAt(cableFrom.point.x, cableFrom.point.y);
					v = sp.vertex;
				}
				if (!graph.connectVertices(cableFrom, v)) {
					trace("couldn't connect :(");
				}
			}
			cableFrom = null;
		}
	}

	override function step(x:Float, y:Float, touching:Bool) {
		renderer.view.centerX += (panTargetX - renderer.view.centerX) * 0.2;
		renderer.view.centerY += (panTargetY - renderer.view.centerY) * 0.2;
		graph.stepPhysics();
		renderer.render(graph);
	}
}
