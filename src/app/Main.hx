package app;

import graph.Vertex;
import graph.Graph;
import haxe.Json;
import graph.serial.GraphData;
import js.Browser;
import pot.core.App;
import pot.input.Input;
import render.Renderer;

class Main extends App {
	public static var inputForDebug:Input;

	var renderer:Renderer;
	var pixelRatio:Int;

	public function new() {
		super(cast Browser.document.getElementById("canvas"), true);
	}

	override function setup() {
		pixelRatio = Std.int(Browser.window.devicePixelRatio);
		pot.sizeMax(pixelRatio);

		var width = 0;
		var height = 0;
		function resize():Void {
			var w = canvas.parentElement.offsetWidth * pixelRatio;
			var h = canvas.parentElement.offsetHeight * pixelRatio;
			if (width != w || height != h) {
				width = w;
				height = h;
				canvas.width = width;
				canvas.height = height;
			}
		}
		canvas.style.width = null;
		canvas.style.height = null;
		Browser.window.addEventListener("resize", resize);
		resize();

		pot.frameRate(60);

		inputForDebug = input;

		init();

		pot.start();
	}

	function init():Void {
		compiler = new WebAudioCompiler();
		var doc = Browser.document;
		var playing = false;
		var toggle = doc.getElementById("toggle");
		toggle.addEventListener("click", () -> {
			if (playing) {
				compiler.stop();
			} else {
				compiler.start();
			}
			playing = !playing;
			if (playing) {
				toggle.classList.remove("highlighted");
				toggle.innerText = "Mute";
			} else {
				toggle.classList.add("highlighted");
				toggle.innerText = "Play";
			}
		});
		doc.getElementById("export").addEventListener("click", () -> {
			var input = doc.createPreElement();
			doc.body.appendChild(input);
			var rootGraph = control.graph;
			while (rootGraph.parent != null) {
				rootGraph = rootGraph.parent;
			}
			input.innerText = Json.stringify(rootGraph.serialize());

			var sel = doc.getSelection();
			sel.selectAllChildren(input);
			doc.execCommand("copy");
			sel.removeAllRanges();
			doc.body.removeChild(input);

			Browser.alert("copied!");
		});
		doc.getElementById("import").addEventListener("click", () -> {
			var text = Browser.window.prompt("paste saved text");
			if (text == null || text == "")
				return;
			try {
				var data:GraphData = Json.parse(text);
				var rootGraph = control.graph;
				while (rootGraph.parent != null) {
					rootGraph = rootGraph.parent;
				}
				var nextGraph = Graph.deserialize(data, rootGraph.listener);
				rootGraph.destroyEverything();
				control.renderer.view.centerX = 0;
				control.renderer.view.centerY = 0;
				control.nextControl = new MainControl(control.context.changeGraph(nextGraph));
			} catch (e:Any) {
				// do nothing
				Browser.alert("couldn't load: " + e);
			}
		});
		doc.getElementById("up").addEventListener("click", () -> {
			octaveShift++;
			prevKeyIndex = -1;
			if (octaveShift > 8)
				octaveShift = 8;
		});
		doc.getElementById("down").addEventListener("click", () -> {
			octaveShift--;
			prevKeyIndex = -1;
			if (octaveShift < 1)
				octaveShift = 1;
		});

		var graph = new Graph(compiler);
		NodeList.OUTPUT.create(graph, 0, 0);

		renderer = new Renderer(canvas);
		renderer.view.scale = (1 + (pixelRatio - 1) * 0.8) * 1.6;
		control = new MainControl(new Context(canvas, graph, renderer, new Clipboard()));
	}

	var cableFrom:Vertex;
	var dragging:Vertex;

	var ppress:Bool = false;
	var pressCount:Int = 0;
	var touchId:Int = -1;

	var beginWorldX:Float = 0;
	var beginWorldY:Float = 0;
	var beginCanvasX:Float = 0;
	var beginCanvasY:Float = 0;

	var prevPressFrame:Int;
	var pressFrame:Int;
	var continuousPressCount:Int = 0;

	var createNodeMode:Bool = false;
	var menuShowCount:Int = 0;

	var control:Control;

	var prevX:Float = 0;
	var prevY:Float = 0;

	var compiler:WebAudioCompiler;

	var touchingBelow:Bool = false;
	var prevKeyIndex:Int = -1;

	var octaveShift:Int = 4;

	override function loop() {
		var x:Float = prevX;
		var y:Float = prevY;
		var press:Bool = false;

		var hasTouchInput:Bool = false;
		if (touchId == -1 && input.touches.length > 0) {
			touchId = input.touches[0].id;
		}
		for (t in input.touches) {
			if (t.id != touchId)
				continue;
			hasTouchInput = true;
			press = t.touching;
			x = t.x;
			y = t.y;
			control.lastInputSource = Touch;
		}
		if (!hasTouchInput) {
			touchId = -1;
			press = input.mouse.left;
			if (press || input.mouse.dx != 0 || input.mouse.dy != 0) {
				x = input.mouse.x;
				y = input.mouse.y;
				control.lastInputSource = Mouse;
			}
		}

		var gx = renderer.worldX(x);
		var gy = renderer.worldY(y);

		// process user inputs

		if (!ppress && press && y > canvas.height * 0.8) {
			touchingBelow = true;
			compiler.attack();
		}
		if (!press) {
			if (touchingBelow) {
				compiler.release();
			}
			touchingBelow = false;
		}

		if (!ppress && press && !touchingBelow) {
			prevPressFrame = pressFrame;
			pressFrame = frameCount;

			var dx = beginCanvasX - x;
			var dy = beginCanvasY - y;
			if (dx * dx + dy * dy > UISetting.dragBeginThreshold * UISetting.dragBeginThreshold)
				continuousPressCount = 0;
			if (frameCount > prevPressFrame + UISetting.longPressTimeThreshold)
				continuousPressCount = 0;
			continuousPressCount++;

			beginCanvasX = x;
			beginCanvasY = y;
			beginWorldX = renderer.worldX(beginCanvasX);
			beginWorldY = renderer.worldY(beginCanvasY);
		}

		if (press || ppress) {
			pressCount++;
		} else {
			pressCount = 0;
			dragging = null;
			cableFrom = null;
		}

		if (!press && ppress && !touchingBelow) {
			control.onReleased(gx, gy, continuousPressCount);
		}

		if (press && pressCount < UISetting.longPressTimeThreshold && !touchingBelow) {
			var dx = beginCanvasX - x;
			var dy = beginCanvasY - y;
			if (dx * dx + dy * dy > UISetting.dragBeginThreshold * UISetting.dragBeginThreshold) {
				control.onDragBegin(beginWorldX, beginWorldY, continuousPressCount);
				continuousPressCount = 0;
				pressCount = 100;
			}
		}
		if (press && pressCount == UISetting.longPressTimeThreshold && !touchingBelow) {
			control.onLongPress(beginWorldX, beginWorldY, continuousPressCount);
			continuousPressCount = 0;
		}
		if (press && ppress && !touchingBelow) {
			control.onPressing(gx, gy);
		}

		control.step(gx, gy, press && ppress && !touchingBelow);

		renderer.fill(0.9, 0.9, 0.9);
		renderer.context().fillRect(0, canvas.height * 0.8, canvas.width, canvas.height * 0.2);
		
		var keyIndex = renderer.renderKeyboard(0, canvas.height * 0.8, canvas.width, canvas.height * 0.2, "C" + octaveShift, x, y, press);
		if (keyIndex != -1 && keyIndex != prevKeyIndex && press) {
			var time = 0.001;
			if (!ppress) {
				time = 0;
			}
			prevKeyIndex = keyIndex;
			var freq = 440 * Math.pow(2, (octaveShift - 4) + (keyIndex - 9) / 12);
			compiler.setFrequency(freq, time);
		}

		renderer.renderTouch(x, y, press && ppress);

		if (control.nextControl != null) {
			control = control.nextControl;
		}

		ppress = press;
		prevX = x;
		prevY = y;
	}

	static function main() {
		new Main();
	}
}
