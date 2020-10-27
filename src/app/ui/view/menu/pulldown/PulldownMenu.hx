package app.ui.view.menu.pulldown;

import app.graphics.Graphics;

class PulldownMenu extends Sprite {
	var shown:Bool = false;
	var scale:Float = 0;

	public function new() {
		super();
	}

	public function isShown():Bool {
		return shown;
	}

	public function show():Void {
		shown = true;
	}

	public function hide():Void {
		shown = false;
	}

	override function update() {
		var targetScale:Float = shown ? 1 : 0;
		scale += (targetScale - scale) * 0.5;
		style.noHit = scale < 0.99;
	}

	override function draw(g:Graphics) {
		g.scale(1, scale);
	}
}
