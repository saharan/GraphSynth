package app;

import render.Renderer;
import graph.Graph;
import js.html.CanvasElement;

class MenuControl extends Control {
	var count:Int;
	var firstX:Float;
	var firstY:Float;

	var menu:Menu;
	var focus:Int;

	var enabled:Bool;

	public function new(context:Context) {
		super(context);
		count = 0;
		firstX = 0;
		firstY = 0;
		focus = -1;
		enabled = false;
	}

	override function step(x:Float, y:Float, touching:Bool) {
		if (count == 0) {
			firstX = x;
			firstY = y;
		}

		var dx = x - firstX;
		var dy = y - firstY;
		var r = UISetting.dragBeginThreshold / renderer.view.scale;
		if (dx * dx + dy * dy > r * r)
			enabled = true;

		if (!touching)
			enabled = true;

		count++;
		graph.stepPhysics();
		renderer.render(graph);
		var menuX = x;
		var menuY = y;
		if (lastInputSource == Touch && !touching || !enabled) {
			menuX = 1e6;
			menuY = 1e6;
		}
		focus = renderer.renderMenu(menu, count / 20, menuX, menuY);
	}
}
