package app.ui.view.main;

import app.graphics.Graphics;
import app.ui.core.Element;

class PointerMarker extends Sprite {
	public final p:Pointer;

	var freq:Int = 12;
	var count:Int = 0;
	var pressed:Bool = false;
	var leftLife:Int = 0;

	public function new(p:Pointer) {
		super();
		this.p = p;
		style.size.set(Zero, Zero);
	}

	public function down():Void {
		pressed = true;
	}

	public function up():Void {
		pressed = false;
	}

	public function die():Void {
		leftLife = 15;
	}

	override function update() {
		if (pressed)
			count++;
		else {
			if (count > 0)
				count++;
			if (count % freq == 0)
				count = 0;
		}
		if (leftLife > 0 && --leftLife == 0) {
			parent.removeChild(this);
		}
	}

	override function draw(g:Graphics) {
		var t = count % freq / freq;
		var strokeR = (1 - (1 - t) * (1 - t)) * 10;
		var strokeA = 1 - t;
		if (pressed) {
			g.fill(0, 0, 0);
			g.circle(p.x, p.y, 3, Fill);
		}
		if (count > 0) {
			g.lineWidth(3);
			g.stroke(0, 0, 0, strokeA);
			g.circle(p.x, p.y, strokeR, Stroke);
		}
	}
}
