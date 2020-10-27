package app.ui.view.main;

import app.ui.view.main.input.InputControllerListener;
import render.View;

using common.FloatTools;

class ViewController implements InputControllerListener {
	final view:View;

	var pinchWorldCenterX:Float;
	var pinchWorldCenterY:Float;
	var pinchBaseScale:Float;

	var panWorldX:Float;
	var panWorldY:Float;

	public function new(view:View) {
		this.view = view;
	}

	public function onClickBegin(x:Float, y:Float):Void {
	}

	public function onClickMove(x:Float, y:Float):Void {
	}

	public function onClickCancel():Void {
	}

	public function onClickEnd():Void {
	}

	public function onPinchBegin(x1:Float, y1:Float, x2:Float, y2:Float):Void {
		pinchWorldCenterX = view.worldX((x1 + x2) * 0.5);
		pinchWorldCenterY = view.worldY((y1 + y2) * 0.5);
		var dist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		if (dist < 1e-6)
			dist = 1e-6;
		pinchBaseScale = view.scale / dist;
	}

	public function onPinchMove(x1:Float, y1:Float, x2:Float, y2:Float):Void {
		var ndist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		view.scale = pinchBaseScale * ndist;
		view.centering((x1 + x2) * 0.5, (y1 + y2) * 0.5, pinchWorldCenterX, pinchWorldCenterY);
	}

	public function onPinchEnd():Void {
	}

	public function onPanBegin(x:Float, y:Float):Void {
		panWorldX = view.worldX(x);
		panWorldY = view.worldY(y);
	}

	public function onPanMove(x:Float, y:Float):Void {
		view.centering(x, y, panWorldX, panWorldY);
	}

	public function onPanEnd():Void {
	}

	public function onWheel(x:Float, y:Float, amount:Float):Void {
		var pivotX = view.worldX(x);
		var pivotY = view.worldY(y);
		var lines = amount / 24;
		view.scale *= Math.pow(1.05, -lines);
		view.centering(x, y, pivotX, pivotY);
	}
}
