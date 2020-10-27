package app.ui.view;

import app.graphics.Graphics;
import app.ui.core.LengthOrAuto;

class Button extends Sprite {
	public var round:Float;
	public var textScale:Float;

	var text:Gen<String>;
	var onClick:Void->Void;

	var state:ButtonState = Default;

	public function new(w:LengthOrAuto, h:LengthOrAuto, text:Gen<String>, onClick:Void->Void, textScale:Float = 1.0) {
		super();
		this.text = text;
		this.onClick = onClick != null ? onClick : () -> {};
		this.textScale = textScale;
		style.size.set(w, h);
		stopEvent = true;
		pointerPolicy = Exclusive;
		cursor = Pointer;
		round = 2;
	}

	inline function hitTest(x:Float, y:Float):Bool {
		return style.hitArea.test(width, height, x, y);
	}

	override function onPointerEnter(p:Pointer) {
		super.onPointerEnter(p);
		if (p.isDown(0))
			onPointerDown(p, 0);
	}

	override function onPointerDown(p:Pointer, index:Int) {
		if (!p.isPrimary || index != 0)
			return;
		switch state {
			case Default | Hover:
				if (hitTest(p.x, p.y)) {
					state = Pressed;
				}
			case Pressed | PressedOut:
		}
	}

	override function onPointerUp(p:Pointer, index:Int) {
		if (!p.isPrimary || index != 0)
			return;
		if (hitTest(p.x, p.y)) {
			state = Hover;
			onClick();
		} else {
			state = Default;
		}
	}

	override function update() {
		var p = pointerManager.primaryPointer;
		var hit = p != null && hitTest(p.x, p.y);
		switch state {
			case Default:
				if (hit)
					state = Hover;
			case Hover:
				if (!hit)
					state = Default;
			case Pressed:
				if (!hit)
					state = PressedOut;
			case PressedOut:
				if (hit)
					state = Pressed;
		}
		if (pointerPolicy == Free) {
			state = hit ? p.isDown(0) ? Pressed : Hover : Default;
		}
	}

	override function draw(g:Graphics) {
		switch state {
			case Default:
				g.fill(1, 1, 1);
			case Hover:
				g.fill(1, 0.6, 0.6);
			case Pressed:
				g.fill(0.6, 0, 0);
			case PressedOut:
				g.fill(0.6, 0.6, 0.6);
		}
		g.stroke(0, 0, 0);
		g.roundRect(0, 0, width, height, round, Both);
		g.textBaseline(Middle);
		g.textAlign(Center);
		switch state {
			case Default | Hover:
				g.fill(0, 0, 0);
			case Pressed | PressedOut:
				g.fill(1, 1, 1);
		}
		g.text(text, width * 0.5, height * 0.5, Fill, textScale);
	}
}
