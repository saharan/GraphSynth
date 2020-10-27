package app.ui;

import app.graphics.Graphics;
import app.ui.core.UI;
import app.ui.view.Font;
import pot.input.CodeValue;
import pot.input.Input;

class Stage {
	final input:Input;
	final g:Graphics;
	final ui:UI;

	public final root:Sprite;
	public var scale:Float = 1;

	final elementMap:Map<Int, Sprite> = [];
	final pointerIdMap:Map<Int, Int> = [];
	final captureMap:Map<Int, Array<Sprite>> = [];

	var pointerIdCount:Int = 0;

	public var cursor(default, null):CursorType = Default;

	var drawBoundary:Bool = false;

	public function new(input:Input, g:Graphics) {
		this.input = input;
		this.g = g;
		ui = new UI();
		root = new Sprite(ui.root);
		root.stage = this;
	}

	public function resize(w:Float, h:Float):Void {
		ui.width = w;
		ui.height = h;
	}

	public function update():Void {
		ui.layout();
		updateMap();
		updateInput(input);
		updateSprite(root);
		ui.layout();
	}

	function updateSprite(s:Sprite):Void {
		s.update();
		var i = 0;
		while (i < s.children.length) {
			var c = s.children[i];
			updateSprite(c);
			if (c.dead) {
				s.removeChild(c);
				continue;
			}
			i++;
		}
	}

	function updateMap():Void {
		elementMap.clear();
		registerMap(root);
	}

	function registerMap(s:Sprite):Void {
		elementMap[s.element.id] = s;
		for (c in s.children)
			registerMap(c);
	}

	function updateInput(input:Input):Void {
		if (input.mouse.enabled) {
			if (captureMap[0] == null)
				captureMap[0] = [];
			updatePointer(0, input.mouse.x, input.mouse.y, (input.mouse.left ? 1 : 0) | (input.mouse.right ? 2 : 0),
				(input.mouse.dleft == 1 ? 1 : 0) | (input.mouse.dright == 1 ? 2 : 0),
				(input.mouse.dleft == -1 ? 1 : 0) | (input.mouse.dright == -1 ? 2 : 0), input.mouse.wheel);
		}
		// register ids
		for (t in input.touches) {
			if (t.dtouching == 1) {
				pointerIdMap.set(t.id, ++pointerIdCount);
				captureMap[pointerIdMap[t.id]] = [];
			}
		}

		for (t in input.touches)
			if (pointerIdMap.exists(t.id))
				updatePointer(pointerIdMap[t.id], t.x, t.y, t.touching ? 1 : 0, t.dtouching == 1 ? 1 : 0, t.dtouching == -1 ? 1 : 0, 0);

		// remove ids
		for (t in input.touches) {
			if (t.dtouching == -1) {
				updateCapture(pointerIdMap[t.id], [], true, 0);
				captureMap.remove(pointerIdMap[t.id]);
				pointerIdMap.remove(t.id);
			}
		}

		// debug
		if (input.keyboard[Space].ddown == 1) {
			drawBoundary = !drawBoundary;
		}
	}

	function updatePointer(id:Int, x:Float, y:Float, downBits:Int, pressedBits:Int, releasedBits:Int, wheelAmount:Float):Void {
		x /= scale;
		y /= scale;
		if (releasedBits != 0) {
			for (i in 0...8)
				if (releasedBits >> i & 1 == 1)
					for (s in captureMap[id])
						s.pointerManager.onUp(id, i);
		}

		var pointerFree = downBits & ~pressedBits == 0;

		var cap = [];
		var hits = ui.hitTest(x, y);
		for (e in hits) {
			var s = elementMap[e.id];
			cap.push(s);
			if (s.stopEvent)
				break;
		}

		updateCapture(id, cap, pointerFree, downBits & ~pressedBits);

		var isMouse = id == 0;
		if (isMouse) {
			cursor = Auto;
			for (s in captureMap[id]) {
				if (s.cursor != Auto) {
					cursor = s.cursor;
					break;
				}
			}
		}

		for (s in captureMap[id]) {
			s.pointerManager.onMove(id, x, y);
		}
		if (wheelAmount != 0) {
			for (s in captureMap[id]) {
				s.pointerManager.onWheel(id, wheelAmount);
			}
		}

		if (pressedBits != 0) {
			for (i in 0...8)
				if (pressedBits >> i & 1 == 1)
					for (s in captureMap[id])
						s.pointerManager.onDown(id, i);
		}
	}

	function updateCapture(id:Int, cap:Array<Sprite>, pointerFree:Bool, downBits:Int):Void {
		var oldCap = captureMap[id];
		var newCap = [];
		var mustLock = false;

		if (!pointerFree) {
			for (s in oldCap) {
				if (s.pointerPolicy == Exclusive) {
					mustLock = true;
					break;
				}
			}
		}

		for (s in oldCap)
			if (!pointerFree && (mustLock || s.pointerPolicy != Free))
				newCap.push(s);
		for (s in cap)
			if (pointerFree || !(mustLock || s.pointerPolicy != Free))
				if (newCap.indexOf(s) == -1)
					newCap.push(s);

		for (s in oldCap)
			if (newCap.indexOf(s) == -1)
				s.pointerManager.onExit(id);
		for (s in newCap)
			if (oldCap.indexOf(s) == -1)
				s.pointerManager.onEnter(id, downBits);

		newCap.sort((a, b) -> {
			var pa = a.element.path;
			var pb = b.element.path;
			return -(pa < pb ? -1 : pa > pb ? 1 : 0);
		});
		captureMap[id] = newCap;
	}

	public function draw():Void {
		g.saved(() -> {
			g.font(Font.FONT_NAME, Font.FONT_BASE_SIZE, Font.BOLD);
			g.scale(scale, scale);
			drawSprite(root);
		});
	}

	function drawSprite(s:Sprite):Void {
		g.saved(() -> {
			var dx = s.x;
			var dy = s.y;
			if (s.parent != null) {
				dx -= s.parent.x;
				dy -= s.parent.y;
			}
			g.translate(dx, dy);
			s.draw(g);
			for (c in s.children) {
				drawSprite(c);
			}
			if (drawBoundary) {
				g.saved(() -> {
					g.lineWidth(0.5);
					g.stroke(0, 0, 1);
					g.rect(s.element.contentStart(X) - s.x, s.element.contentStart(Y) - s.y, s.element.contentSize(X),
						s.element.contentSize(Y), Stroke);
					g.stroke(1, 0, 0);
					g.rect(0, 0, s.width, s.height, Stroke);
				});
			}
		});
	}
}
