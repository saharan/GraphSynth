package render;

import graph.NodePhys;
import app.Menu;
import graph.Graph;
import graph.Node;
import graph.Socket;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Renderer {
	static inline final PI:Float = 3.141592653589793;
	static inline final TWO_PI:Float = PI * 2;
	static inline final HALF_PI:Float = PI * 0.5;

	public static inline final FILL:Int = 1;
	public static inline final STROKE:Int = 2;

	final canvas:CanvasElement;
	final c2d:CanvasRenderingContext2D;

	public final view:View;

	var touchingCount:Int = 0;

	public var canvasCenterHeightRatio:Float;

	final waveData:Array<Float>;

	public function new(canvas:CanvasElement) {
		this.canvas = canvas;
		view = new View();
		c2d = canvas.getContext2d();
		canvasCenterHeightRatio = 0.4;
		waveData = [];
	}

	public function context():CanvasRenderingContext2D {
		return c2d;
	}

	public function render(graph:Graph):Void {
		if (graph.updateRequired)
			graph.updateConnections();
		fill(1, 1, 1);
		c2d.fillRect(0, 0, canvas.width, canvas.height);
		customRender(() -> {
			drawGraph(graph);
		});
	}

	public function renderTouch(canvasX:Float, canvasY:Float, touching:Bool) {
		var x:Float = worldX(canvasX);
		var y:Float = worldY(canvasY);
		if (touching)
			touchingCount++;
		else {
			if (touchingCount > 0)
				touchingCount++;
			if (touchingCount % 12 == 0)
				touchingCount = 0;
		}
		var t = touchingCount % 12 / 12;
		var strokeR = (1 - (1 - t) * (1 - t)) * 10;
		var strokeA = 1 - t;
		customRender(() -> {
			if (touching) {
				fill(0, 0, 0);
				circle(x, y, 3, Renderer.FILL);
			}
			if (touchingCount > 0) {
				c2d.lineWidth = 3;
				stroke(0, 0, 0, strokeA);
				circle(x, y, strokeR, Renderer.STROKE);
			}
		});
	}

	public function renderKeyboard(offsetX:Float, offsetY:Float, width:Float, height:Float, text:String, touchCanvasX:Float,
			touchCanvasY:Float, touching:Bool):Int {
		var result = -1;
		translated(offsetX, offsetY, () -> {
			touchCanvasX -= offsetX;
			touchCanvasY -= offsetY;

			var stroke:Float = 1.5 * view.scale;
			var blackKeyWidthRatio:Float = 0.6;
			var blackKeyHeightRatio:Float = 0.5;
			var blackKeyHitWidthScale:Float = 1.5;
			var keyWidth:Float = 24 * view.scale;
			var numKeys:Int = Math.ceil((width - stroke) / keyWidth);
			keyWidth = (width - stroke) / numKeys;

			inline function whiteKey(x:Float, y:Float, w:Float, h:Float, draw:Bool, focused:Bool = false):Bool {
				if (draw) {
					fill(0, 0, 0);
					c2d.fillRect(x, y, w, h);
					if (focused)
						fill(1, 0.6, 0.6);
					else
						fill(1, 1, 1);
					c2d.fillRect(x, y + stroke, w - stroke, h - stroke * 2);
					if (!focused) {
						var shadowH = keyWidth * 0.6;
						fill(0.8, 0.8, 0.8);
						c2d.fillRect(x, y + h - shadowH + stroke, w - stroke, shadowH - stroke * 2);
					}
				}
				return touchCanvasX > x && touchCanvasX < x + w - stroke && touchCanvasY > y + stroke && touchCanvasY < y + h - stroke;
			}

			inline function blackKey(x:Float, y:Float, w:Float, h:Float, draw:Bool, focused:Bool = false):Bool {
				if (draw) {
					fill(0, 0, 0);
					c2d.fillRect(x, y, w, h);
					if (focused) {
						fill(0.6, 0, 0);
						c2d.fillRect(x + stroke, y + stroke, w - stroke * 2, h - stroke * 2);
					}
					if (!focused) {
						var shadowH = keyWidth * 0.5;
						fill(0.4, 0.4, 0.4);
						c2d.fillRect(x + stroke, y + h - shadowH + stroke, w - stroke * 2, shadowH - stroke * 2);
					}
				}
				var dx = x + w * 0.5 - touchCanvasX;
				return (dx < 0 ? -dx : dx) < keyWidth * 0.5 * blackKeyWidthRatio * blackKeyHitWidthScale
					&& touchCanvasY > y + stroke
					&& touchCanvasY < y + h - stroke;
			}

			fill(0, 0, 0);
			c2d.fillRect(0, 0, stroke, height);
			var blackKeyExists = [true, true, false, true, true, true, false];
			var whiteIndex = -1;
			var blackIndex = -1;

			// hit test
			for (i in 0...numKeys) {
				if (whiteKey(stroke + keyWidth * i, 0, keyWidth, height, false)) {
					whiteIndex = i;
				}
			}
			for (i in 0...numKeys - 1) {
				if (blackKeyExists[i % blackKeyExists.length]) {
					var blackCenter = stroke + keyWidth * (i + 1);
					if (blackKey(blackCenter - keyWidth * blackKeyWidthRatio * 0.5, 0, keyWidth * blackKeyWidthRatio,
						height * blackKeyHeightRatio, false)) {
						blackIndex = i;
					}
				}
			}
			if (blackIndex != -1) {
				whiteIndex = -1;
			}
			// draw
			for (i in 0...numKeys) {
				whiteKey(stroke + keyWidth * i, 0, keyWidth, height, true, touching && i == whiteIndex);
				if (i == 0) {
					fill(0, 0, 0);
					c2d.textAlign = "center";
					this.text(text, stroke + keyWidth * (i + 0.5), height * 0.7 + (touching && i == whiteIndex ? keyWidth * 0.2 : 0.0),
						view.scale);
				}
			}
			for (i in 0...numKeys - 1) {
				if (blackKeyExists[i % blackKeyExists.length]) {
					var blackCenter = stroke + keyWidth * (i + 1);
					blackKey(blackCenter - keyWidth * blackKeyWidthRatio * 0.5, 0, keyWidth * blackKeyWidthRatio,
						height * blackKeyHeightRatio, true, touching
						&& i == blackIndex);
				}
			}
			// index check
			var keyIndex = 0;
			for (i in 0...numKeys) {
				if (whiteIndex == i) {
					result = keyIndex;
					return;
				}
				keyIndex++;
				if (blackKeyExists[i % blackKeyExists.length]) {
					if (blackIndex == i) {
						result = keyIndex;
						return;
					}
					keyIndex++;
				}
			}
		});
		return result;
	}

	public extern inline function customRender(f:Void->Void) {
		c2d.lineCap = "round";
		c2d.textBaseline = "middle";
		c2d.font = "bold 10px \"Courier New\"";
		translated(canvas.width * 0.5, canvas.height * canvasCenterHeightRatio, () -> {
			c2d.scale(view.scale, view.scale);
			c2d.translate(-view.centerX, -view.centerY);
			f();
		});
	}

	public function renderMenu(menu:Menu, time:Float, x:Float, y:Float):Int {
		fill(1, 1, 1, 0.9);
		c2d.fillRect(0, 0, canvas.width, canvas.height);

		if (time < 1) {
			x = 0;
			y = 0;
		} else {
			x -= view.centerX;
			y -= view.centerY;
			y += canvas.height / view.scale * canvasCenterHeightRatio;
		}

		var t = time > 1 ? 1 : time;
		t = 1 - t;
		t = t * t * t * t;
		t = 1 - t;

		var res;
		translated(canvas.width * 0.5, 0, () -> {
			c2d.scale(view.scale, view.scale * t);
			res = drawMenu(menu, x, y);
		});
		return res;
	}

	function drawMenu(menu:Menu, mx:Float, my:Float):Int {
		fill(0, 0, 0);
		stroke(0, 0, 0);
		var y:Float = canvas.height / view.scale * 0.15;
		c2d.textAlign = "center";
		c2d.lineWidth = 0.5;
		text(menu.title, 0, y, false, true, 2.0);
		y += 24;
		c2d.textAlign = "left";
		var result = -1;
		var idx = 0;
		for (i in 0...menu.items.length) {
			var row = menu.items[i];
			if (row.length == 0) {
				y += 6;
				continue;
			}
			var minX = -125.0;
			var width = 250 / row.length;
			var colX = minX;
			for (item in row) {
				if (item != null) {
					fill(0, 0, 0);
					if (mx > colX && mx < colX + width && my > y - 10 && my < y + 10) {
						fill(0.6, 0, 0);
						stroke(0.6, 0, 0);
						result = idx;
						c2d.lineWidth = 1;
						c2d.beginPath();
						c2d.moveTo(colX, y + 10);
						c2d.lineTo(colX + width, y + 10);
						c2d.stroke();
					}
					circle(colX + 10, y, 3, FILL);
					text(item, colX + 20, y, 1.2);
				}
				colX += width;
				idx++;
			}
			y += 20;
		}
		return result;
	}

	function createLabelForSocket(s:Socket, name:String):Void {
		inline function makeLabel(alignLeft:Bool):CanvasElement {
			var c = Browser.document.createCanvasElement();
			c.width = 120;
			c.height = 30;
			var c2d = c.getContext2d();
			c2d.textAlign = alignLeft ? "left" : "right";
			c2d.font = "bold 30px \"Courier New\"";
			c2d.fillStyle = "rgb(0,0,0)";
			c2d.strokeStyle = "rgb(255,255,255)";
			c2d.lineWidth = 8;
			var x = alignLeft ? c2d.lineWidth : c.width - c2d.lineWidth;
			c2d.strokeText(name, x, c.height * 0.5);
			c2d.fillText(name, x, c.height * 0.6);
			return c;
		}
		s.phys.labels = [makeLabel(true), makeLabel(false)];
		s.phys.labelText = name;
	}

	function drawGraph(graph:Graph):Void {
		waveData.resize(0);
		graph.listener.onWaveDataRequest(waveData);

		drawCables(graph);
		for (n in graph.nodes) {
			drawNode(n);
		}
		for (n in graph.nodes) {
			for (s in n.sockets) {
				drawSocket(n, s);
			}
		}
	}

	function drawCables(graph:Graph):Void {
		for (v in graph.vertices) {
			v.tmpValForRendering = 0; // reset rendering flag
		}

		c2d.lineWidth = 1;
		stroke(0, 0, 0);
		c2d.beginPath();
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
						c2d.moveTo(sp.vertex.point.x, sp.vertex.point.y);
						c2d.lineTo(s2p.vertex.point.x, s2p.vertex.point.y);
					}
				}
			}
		}
		c2d.stroke();

		stroke(0, 0, 0);
		c2d.beginPath();
		for (e in graph.edges) {
			if (e.v1.tmpValForRendering == 1 || e.v2.tmpValForRendering == 1)
				continue;
			if (!e.v1.type.match(Node(_)) && !e.v2.type.match(Node(_))) {
				c2d.moveTo(e.v1.point.x, e.v1.point.y);
				c2d.lineTo(e.v2.point.x, e.v2.point.y);
			}
		}
		c2d.stroke();

		var drawVertices = false;
		if (drawVertices) {
			fill(1, 0, 0);
			for (v in graph.vertices) {
				if (v.type != Normal)
					continue;
				circle(v.point.x, v.point.y, 1, FILL);
			}
		}
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
			stroke(0.7, 0.7, 0.7);
		else
			stroke(0, 0, 0);
		c2d.beginPath();
		c2d.moveTo(x - radius, y);
		if (waveData.length > 0) {
			for (i in 0...div + 1) {
				var t = i / div * 2 - 1;
				var scale = 0.6;
				var maxAmp = Math.min(scale, Math.sqrt(1 - t * t));
				var amp = getValueAt((t + 1) * 0.5) * scale;
				amp = clampF(amp, -maxAmp, maxAmp);
				c2d.lineTo(x + t * radius, y - amp * radius);
				c2d.moveTo(x + t * radius, y - amp * radius);
			}
		}
		c2d.lineTo(x + radius, y);
		c2d.stroke();
	}

	function drawNode(node:Node):Void {
		var isDestination = node.setting.role.match(Destination);
		c2d.lineWidth = 1;

		var np = node.phys;
		var x = np.vertex.point.x;
		var y = np.vertex.point.y;

		if (isDestination)
			drawOutputWave(x, y, np.radius);

		stroke(0, 0, 0);
		fill(0, 0, 0);
		circle(x, y, np.radius, STROKE);

		if (node.selected) {
			node.selectingCount++;
			var t = node.selectingCount % 40 / 40;
			var strokeR = (1 - (1 - t) * (1 - t)) * 0.5;
			var strokeA = 1 - t;
			c2d.lineWidth = 1 + (1 - strokeA) * 5 * (node.phys.radius / NodePhys.DEFAULT_RADIUS);
			stroke(0, 0, 0, strokeA);
			circle(x, y, np.radius * (1 + strokeR), Renderer.STROKE);
			c2d.lineWidth = 1;
		}

		switch (node.type) {
			case Boundary(type):
				var innerCircleSize = 0.8;
				switch (type) {
					case I:
						var radDiff = np.radius * (1 - innerCircleSize);
						c2d.lineWidth = radDiff;
						circle(x, y, np.radius * (1 + innerCircleSize) * 0.5, STROKE);
						c2d.lineWidth = 1;
					case O:
						circle(x, y, np.radius * innerCircleSize, STROKE);
				}
			case _:
		}

		var textY = isDestination ? y - np.radius * 0.75 : y;
		c2d.textAlign = "center";
		switch (node.setting.role) {
			case Number(num):
				text(Std.string(num.value), x, textY);
			case _:
				text(node.setting.name, x, textY);
		}
	}

	function drawSocket(node:Node, socket:Socket):Void {
		var sp = socket.phys;
		sp.computeDrawingPos();

		stroke(0, 0, 0);
		circle(sp.xForDrawing, sp.yForDrawing, sp.radius, switch (socket.type.io()) {
			case I:
				FILL | STROKE;
			case O:
				STROKE;
		});

		var name = switch (socket.type) {
			case Param(_, name): name;
			case Module(_, boundary): boundary.setting.name;
			case Normal(_): "";
		}
		if (name != "") {
			if (sp.labels == null || sp.labelText != name)
				createLabelForSocket(socket, name);
			var l1 = sp.labels[0];
			var l2 = sp.labels[1];
			var scale = 0.25;

			var angle:Float = Math.atan2(sp.normalY, sp.normalX);
			var np = node.phys;
			var x = np.vertex.point.x;
			var y = np.vertex.point.y;
			c2d.save();
			stroke(1, 1, 1);
			c2d.translate(x, y);
			c2d.rotate(angle);
			c2d.translate(np.radius + sp.radius * 2 - 1, 0);
			c2d.scale(scale, scale);
			if (sp.normalX < 0) {
				rotated(PI, () -> {
					c2d.drawImage(l2, -l1.width, -l1.height * 0.5);
				});
			} else {
				c2d.drawImage(l1, 0, -l1.height * 0.5);
			}
			c2d.restore();
		}
	}

	public inline function worldX(canvasX:Float):Float {
		return (canvasX - canvas.width * 0.5) / view.scale + view.centerX;
	}

	public inline function worldY(canvasY:Float):Float {
		return (canvasY - canvas.height * canvasCenterHeightRatio) / view.scale + view.centerY;
	}

	public inline function canvasX(worldX:Float):Float {
		return (worldX - view.centerX) * view.scale + canvas.width * 0.5;
	}

	public inline function canvasY(worldY:Float):Float {
		return (worldY - view.centerY) * view.scale + canvas.height * canvasCenterHeightRatio;
	}

	extern public inline function circle(x:Float, y:Float, r:Float, mode:Int):Void {
		c2d.beginPath();
		c2d.arc(x, y, r, 0, TWO_PI);
		if (mode & FILL != 0)
			c2d.fill();
		if (mode & STROKE != 0)
			c2d.stroke();
	}

	extern public inline function text(s:String, x:Float, y:Float, ?fill:Bool = true, ?stroke:Bool = false, ?scale:Float = 1.0):Void {
		if (scale != 1.0) {
			c2d.save();
			c2d.translate(x, y);
			c2d.scale(scale, scale);
			text(s, 0, 0, fill, stroke, 1.0);
			c2d.restore();
			return;
		}
		if (stroke)
			c2d.strokeText(s, x, y);
		if (fill)
			c2d.fillText(s, x, y);
	}

	extern public inline function translated(x:Float, y:Float, draw:Void->Void):Void {
		c2d.save();
		c2d.translate(x, y);
		draw();
		c2d.restore();
	}

	extern public inline function scaled(sx:Float, sy:Float, draw:Void->Void):Void {
		c2d.save();
		c2d.scale(sx, sy);
		draw();
		c2d.restore();
	}

	extern public inline function rotated(rad:Float, draw:Void->Void):Void {
		c2d.save();
		c2d.rotate(rad);
		draw();
		c2d.restore();
	}

	public inline function fill(r:Float, g:Float, b:Float, a:Float = 1.0):Void {
		c2d.fillStyle = 'rgba(${Std.int(r * 255.0)},${Std.int(g * 255.0)},${Std.int(b * 255.0)},$a)';
	}

	public inline function stroke(r:Float, g:Float, b:Float, a:Float = 1.0):Void {
		c2d.strokeStyle = 'rgba(${Std.int(r * 255.0)},${Std.int(g * 255.0)},${Std.int(b * 255.0)},$a)';
	}
}
