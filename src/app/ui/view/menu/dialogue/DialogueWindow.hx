package app.ui.view.menu.dialogue;

import app.graphics.Graphics;

class DialogueWindow extends Sprite {
	public function new() {
		super();
	}

	override function draw(g:Graphics) {
		g.stroke(0, 0, 0);
		g.fill(1, 1, 1);
		g.roundRect(0, 0, width, height, 4, Both);
	}
}
