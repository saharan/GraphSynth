package pot.input;

import js.html.WheelEvent;
import js.html.PointerEvent;
import js.html.CanvasElement;
import js.html.Element;
import js.html.MouseEvent;
import js.html.webgl.ContextEvent;
import pot.core.Pot;

using pot.input.InputTools;

/**
 * ...
 */
@:allow(pot.input.Input)
class Mouse {
	public var px(default, null):Float;
	public var py(default, null):Float;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var dx(default, null):Float;
	public var dy(default, null):Float;
	public var pleft(default, null):Bool;
	public var pmiddle(default, null):Bool;
	public var pright(default, null):Bool;
	public var left(default, null):Bool;
	public var middle(default, null):Bool;
	public var right(default, null):Bool;
	public var dleft(default, null):Int;
	public var dmiddle(default, null):Int;
	public var dright(default, null):Int;
	public var wheel(default, null):Float;
	public var enabled(default, null):Bool;

	var nx:Float;
	var ny:Float;
	var nleft:Bool;
	var nleft2:Bool;
	var nmiddle:Bool;
	var nmiddle2:Bool;
	var nright:Bool;
	var nright2:Bool;
	var nwheel:Float;

	public function new() {
		px = 0;
		py = 0;
		x = 0;
		y = 0;
		nx = 0;
		ny = 0;
		dx = 0;
		dy = 0;
		wheel = 0;
		nwheel = 0;
		pleft = false;
		pmiddle = false;
		pright = false;
		left = false;
		middle = false;
		right = false;
		nleft = false;
		nmiddle = false;
		nright = false;
		dleft = 0;
		dmiddle = 0;
		dright = 0;
		enabled = false;
	}

	function addEvents(canvas:CanvasElement, elem:Element, input:Input, pot:Pot):Void {
		elem.addEventListener("mousedown", (e:MouseEvent) -> {
			enabled = true;
			if (e.cancelable)
				e.preventDefault();
			switch (e.button) {
				case 0:
					nleft = true;
					nleft2 = true;
				case 1:
					nmiddle = true;
					nmiddle2 = true;
				case 2:
					nright = true;
					nright2 = true;
			}
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelRatio);
		});
		elem.addEventListener("mouseup", (e:MouseEvent) -> {
			enabled = true;
			if (e.cancelable)
				e.preventDefault();
			switch (e.button) {
				case 0:
					nleft = false;
				case 1:
					nmiddle = false;
				case 2:
					nright = false;
			}
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelRatio);
		});
		elem.addEventListener("mousemove", (e:MouseEvent) -> {
			enabled = true;
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelRatio);
		});
		elem.addEventListener("wheel", (e:WheelEvent) -> {
			var pixelsPerLine = 24;
			var linesPerPage = 30;
			var scale = switch e.deltaMode {
				case 0:
					1;
				case 1:
					pixelsPerLine;
				case 2:
					pixelsPerLine * linesPerPage;
				case _:
					throw "invalid wheel delta mode";
			}
			var wheelAmount = e.deltaY * scale;
			nwheel += wheelAmount;
			e.preventDefault();
		});
		elem.addEventListener("contextmenu", (e:ContextEvent) -> {
			enabled = true;
			e.preventDefault();
		});
		elem.addEventListener("pointerdown", (e:PointerEvent) -> {
			elem.setPointerCapture(e.pointerId);
		});
		elem.addEventListener("pointerup", (e:PointerEvent) -> {
			elem.releasePointerCapture(e.pointerId);
		});
	}

	function update():Void {
		px = x;
		py = y;
		x = nx;
		y = ny;
		dx = x - px;
		dy = y - py;
		pleft = left;
		pmiddle = middle;
		pright = right;
		left = nleft || nleft2;
		middle = nmiddle || nmiddle2;
		right = nright || nright2;
		nleft2 = false;
		nmiddle2 = false;
		nright2 = false;
		dleft = (left ? 1 : 0) - (pleft ? 1 : 0);
		dmiddle = (middle ? 1 : 0) - (pmiddle ? 1 : 0);
		dright = (right ? 1 : 0) - (pright ? 1 : 0);
		wheel = nwheel;
		nwheel = 0;
	}
}
