package app.ui.view.menu;

import app.graphics.Graphics;

class Underlined extends Button {
	var lineT:Float = 0;
	var selectedCount:Int = 0;

	public function new(text:Gen<String>, onClick:Void->Void) {
		super(Auto, Auto, text, onClick);
		textScale = Menu.FONT_SIZE;

		pointerPolicy = Free;
		style.margin.all(Zero);
	}

	override function update() {
		super.update();
		switch state {
			case Default | PressedOut:
				lineT += (0 - lineT) * 0.5;
				if (lineT < 0.001)
					lineT = 0;
			case Hover | Pressed:
				lineT = 1;
		}
		if (selectedCount > 0) {
			if (selectedCount++ == Menu.ANIMATION_DURATION) {
				selectedCount = 0;
			}
		}
	}

	override function draw(g:Graphics) {
		g.stroke(0.6, 0, 0);
		g.lineWidth(1);
		g.line(0, height, width * lineT, height);
	}
}
