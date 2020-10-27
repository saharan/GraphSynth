package app.ui.view.main;

import graph.NodeViewData;
import graph.NodePhys;
import graph.Vertex;
import app.graphics.Graphics;
import app.ui.view.main.graph.GraphWrapper;
import graph.Node;
import graph.Selection;
import graph.Socket;
import graph.SocketPhys;
import js.Browser;
import js.html.CanvasElement;

class GraphRenderer {
	final waveData:Array<Float>;
	var g:Graphics;
	var graph:GraphWrapper;

	var trailRenderCount:Int = 0;
	var selectionRenderCount:Int = 0;

	public function new(waveData:Array<Float>) {
		this.waveData = waveData;
	}

	public function draw(g:Graphics, graph:GraphWrapper):Void {
		this.g = g;
		this.graph = graph;
		selectionRenderCount++;
		g.textBaseline(Middle);
		drawCables();
		for (n in graph.nodes) {
			drawNode(n, graph.selection.contains(n) ? Selected : Normal);
		}
		for (n in graph.nodes) {
			for (s in n.sockets) {
				drawSocket(n, s);
			}
		}
		for (ns in graph.nodeShadows) {
			if (ns.hidden)
				continue;
			drawNode(ns, Shadow);
		}
		for (cs in graph.connectionShadows) {
			drawShadowConnection(cs.v1, cs.v2, cs.ok);
		}
		drawTrail();
	}

	function drawShadowConnection(src:Vertex, dst:Vertex, ok:Bool):Void {
		if (!ok)
			return;
		var x1 = src.point.x;
		var y1 = src.point.y;
		var r1 = switch src.type {
			case Node(n):
				n.phys.radius;
			case Socket(_):
				0;
			case Normal:
				0;
		};
		var x2 = dst.point.x;
		var y2 = dst.point.y;
		var r2 = switch dst.type {
			case Node(n):
				n.phys.radius;
			case Socket(_):
				0;
			case Normal:
				0;
		};
		var dx = x2 - x1;
		var dy = y2 - y1;
		var l = Math.sqrt(dx * dx + dy * dy);
		var invL = l == 0 ? 0 : 1 / l;
		var nx = dx * invL;
		var ny = dy * invL;
		x1 += nx * r1;
		y1 += ny * r1;
		x2 -= nx * r2;
		y2 -= ny * r2;
		var alpha = 0.5;
		g.lineWidth(1);
		g.stroke(0, 0, 0, alpha);
		g.line(x1, y1, x2, y2);
	}

	function drawTrail():Void {
		var trail = graph.trail;
		if (trail.poss.length < 2)
			return;
		trailRenderCount++;
		var alpha = 0.5 + 0.2 * Math.sin(trailRenderCount * 0.1);
		g.stroke(0, 0, 0, alpha);
		g.fill(0, 0, 0, alpha);
		g.lineJoin(Bevel);
		g.lineWidth(1 / graph.view.scale); // invariant with scale
		g.beginPath();
		var first = trail.firstPos();
		var last = trail.lastPos();
		g.moveTo(first.x, first.y);
		trail.forEachInternalPos(pos -> g.lineTo(pos.x, pos.y));
		g.lineTo(last.x, last.y);
		if (trail.isLasso) {
			g.fillPath();
		} else {
			g.strokePath();
		}
	}

	function drawSelection(x:Float, y:Float, r:Float):Void {
		var t = selectionRenderCount % 40 / 40;
		var selR = 4;
		var strokeR = (1 - (1 - t) * (1 - t)) * 0.5 * selR;
		var strokeA = 1 - t;
		g.lineWidth(strokeR * 2);
		g.stroke(0, 0, 0, strokeA);
		g.circle(x, y, r + strokeR, Stroke);
		g.lineWidth(1);
	}

	function drawOutputWave(x:Float, y:Float, radius:Float):Void {
		inline function clampI(a:Int, min:Int, max:Int):Int {
			return a < min ? min : a > max ? max : a;
		}
		inline function clampF(a:Float, min:Float, max:Float):Float {
			return a < min ? min : a > max ? max : a;
		}
		// linear interpolation
		inline function getValueAt(t:Float):Float {
			var len = waveData.length;
			var indexF = t * len;
			var index = Math.floor(indexF);
			var index2 = index + 1;
			var fract = indexF - index;
			index = clampI(index, 0, len - 1);
			index2 = clampI(index2, 0, len - 1);
			var v1 = waveData[index];
			var v2 = waveData[index2];
			return v1 + (v2 - v1) * fract;
		}

		var div = 128;
		if (waveData.length == 0)
			g.stroke(0.7, 0.7, 0.7);
		else
			g.stroke(0, 0, 0);
		g.beginPath();
		g.lineJoin(Round);
		g.moveTo(x - radius, y);
		if (waveData.length > 0) {
			for (i in 0...div + 1) {
				var t = i / div * 2 - 1;
				var scale = 0.6;
				var maxAmp = Math.min(scale, Math.sqrt(1 - t * t));
				var amp = getValueAt((t + 1) * 0.5) * scale;
				amp = clampF(amp, -maxAmp, maxAmp);
				g.lineTo(x + t * radius, y - amp * radius);
			}
		}
		g.lineTo(x + radius, y);
		g.strokePath();
	}

	function createLabelForSocket(s:Socket, name:String):Void {
		inline function makeLabel(alignLeft:Bool, grayedOut:Bool):CanvasElement {
			var c = Browser.document.createCanvasElement();
			c.width = 120;
			c.height = 50;
			var g = c.getContext2d();
			g.textAlign = alignLeft ? "left" : "right";
			g.font = (Font.BOLD ? "bold " : "") + (Font.FONT_BASE_SIZE * 3 + "px ") + ("\"" + Font.FONT_NAME + "\"");
			g.fillStyle = grayedOut ? "rgb(128,128,128)" : "rgb(0,0,0)";
			g.strokeStyle = "rgb(255,255,255)";
			g.lineWidth = 8;
			var x = alignLeft ? g.lineWidth : c.width - g.lineWidth;
			g.strokeText(name, x, c.height * 0.5);
			g.fillText(name, x, c.height * 0.5);
			return c;
		}
		s.phys.labels = [for (grayedOut in [false, true]) {
			for (alignLeft in [true, false]) {
				makeLabel(alignLeft, grayedOut);
			}
		}];
		s.phys.labelText = name;
	}

	function drawSocket(node:Node, socket:Socket):Void {
		var sp = socket.phys;
		sp.computeDrawingPos();

		var r = sp.radius;
		var x = sp.xForDrawing;
		var y = sp.yForDrawing;

		g.stroke(0, 0, 0);
		g.circle(x, y, r, switch (socket.type.io()) {
			case I:
				Both;
			case O:
				Stroke;
		});

		var selected = graph.socketSelection.contains(socket);
		if (selected) {
			drawSelection(x, y, r);
		}

		var name = switch (socket.type) {
			case Param(_, name):
				name;
			case Module(_, boundary):
				boundary.setting.name;
			case Normal(_):
				"";
		}
		if (name != "") {
			if (sp.labels == null || sp.labelText != name)
				createLabelForSocket(socket, name);
			var scale = selected ? 0.35 : 0.25;

			var images = (socket.grayedOut ? [2, 3] : [0, 1]).map(i -> sp.labels[i]);

			var angle:Float = Math.atan2(sp.normalY, sp.normalX);
			var np = node.phys;
			var x = np.vertex.point.x;
			var y = np.vertex.point.y;

			drawLabel(x, y, np.radius, sp.radius, angle, scale, images);
		}
	}

	function drawLabel(x:Float, y:Float, nodeRadius:Float, socketRadius:Float, angle:Float, scale:Float,
			images:Array<CanvasElement>):Void {
		var l1 = images[0];
		var l2 = images[1];
		g.saved(() -> {
			g.stroke(1, 1, 1);
			g.translate(x, y);
			g.rotate(angle);
			g.translate(nodeRadius + socketRadius * 2 - 1, 0);
			g.scale(scale, scale);
			if (Math.abs(angle) > Math.PI / 2) {
				g.rotated(Math.PI, () -> {
					g.image(l2, -l1.width, -l1.height * 0.4);
				});
			} else {
				g.image(l1, 0, -l1.height * 0.4);
			}
		});
	}

	function drawNode(node:NodeViewData, mode:NodeRenderMode):Void {
		var x = node.getX();
		var y = node.getY();

		var isDestination = node.getRole() == Destination;
		g.lineWidth(1);

		var r = node.getRadius();
		var alpha = mode == Shadow ? 0.5 : 1.0;

		if (isDestination && mode != Shadow)
			drawOutputWave(x, y, r);

		g.stroke(0, 0, 0, alpha);
		g.fill(0, 0, 0, alpha);

		g.circle(x, y, r, Stroke);

		if (mode == Selected) {
			drawSelection(x, y, r);
		}
		g.stroke(0, 0, 0, alpha);

		switch (node.getType()) {
			case Boundary(io):
				var innerCircleSize = r - 0.3 * NodePhys.DEFAULT_RADIUS;
				switch (io) {
					case I:
						var radDiff = r - innerCircleSize;
						g.lineWidth(radDiff);
						g.circle(x, y, r - radDiff * 0.5, Stroke);
						g.lineWidth(1);
					case O:
						g.circle(x, y, innerCircleSize, Stroke);
				}
			case _:
		}

		var textY = isDestination ? y - r * 0.75 : y;
		g.textAlign(Center);
		g.text(node.getText(), x, textY, Fill);
	}

	function drawCables():Void {
		for (v in graph.vertices) {
			v.tmpValForRendering = 0; // reset rendering flag
		}

		g.lineCap(Round);
		g.lineWidth(1);
		g.stroke(0, 0, 0);
		g.beginPath();
		var visited = [];
		for (n in graph.nodes) {
			for (s in n.sockets) {
				if (s.type.io() != O)
					continue;
				for (c in s.connections) {
					var s2 = c.to;
					var fromV = s.phys.vertex;
					var toV = s2.phys.vertex;
					visited.resize(0);

					var x1 = fromV.point.x;
					var y1 = fromV.point.y;
					var x2 = toV.point.x;
					var y2 = toV.point.y;
					var dx = x2 - x1;
					var dy = y2 - y1;
					var len = Math.sqrt(dx * dx + dy * dy);
					var invLen = len == 0 ? 0 : 1 / len;
					var tx = -dy * invLen;
					var ty = dx * invLen;

					var pv = fromV;
					var v = c.firstEdge.other(pv);
					var ng = false;
					while (true) {
						if (v == toV)
							break;
						if (v.edges.length != 2)
							throw "invalid topology: " + v.edges.length;

						visited.push(v);
						var deviation = (v.point.x - x1) * tx + (v.point.y - y1) * ty;
						if (deviation * deviation > 0.1 * 0.1) {
							ng = true;
							break;
						}

						var v1 = v.edges[0].other(v);
						var v2 = v.edges[1].other(v);
						var nv = v1 != pv ? v1 : v2;
						pv = v;
						v = nv;
					}
					if (!ng) {
						for (v in visited) {
							v.tmpValForRendering = 1; // skip rendering edges that include this vertex
						}
						var sp = s.phys;
						var s2p = s2.phys;
						g.moveTo(sp.vertex.point.x, sp.vertex.point.y);
						g.lineTo(s2p.vertex.point.x, s2p.vertex.point.y);
					}
				}
			}
		}
		g.strokePath();

		g.stroke(0, 0, 0);
		g.beginPath();
		for (e in graph.edges) {
			if (e.v1.tmpValForRendering == 1 || e.v2.tmpValForRendering == 1)
				continue;
			if (!e.v1.type.match(Node(_)) && !e.v2.type.match(Node(_))) {
				g.moveTo(e.v1.point.x, e.v1.point.y);
				g.lineTo(e.v2.point.x, e.v2.point.y);
			}
		}
		g.strokePath();

		// TODO: selection for edges?
		// for (v in graph.vertices) {
		// 	if (v.type != Normal)
		// 		continue;
		// 	if (v.selection.selected) {
		// 		var x = v.point.x;
		// 		var y = v.point.y;
		// 		var r = SocketPhys.RADIUS_SMALL;
		// 		g.fill(0, 0, 0);
		// 		g.circle(x, y, r, Fill);
		// 		drawSelection(x, y, r, v.selection);
		// 	}
		// }

		var drawVertices = false;
		if (drawVertices) {
			g.fill(1, 0, 0);
			for (v in graph.vertices) {
				if (v.type != Normal)
					continue;
				g.circle(v.point.x, v.point.y, 1, Fill);
			}
		}
	}
}
