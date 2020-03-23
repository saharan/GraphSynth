package pot.input;
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

	var nx:Float;
	var ny:Float;
	var nleft:Bool;
	var nleft2:Bool;
	var nmiddle:Bool;
	var nmiddle2:Bool;
	var nright:Bool;
	var nright2:Bool;

	public function new() {
		px = 0;
		py = 0;
		x = 0;
		y = 0;
		nx = 0;
		ny = 0;
		dx = 0;
		dy = 0;
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
	}

	function addEvents(canvas:CanvasElement, elem:Element, input:Input, pot:Pot):Void {
		elem.addEventListener("mousedown", (e:MouseEvent) -> {
			if (e.cancelable) e.preventDefault();
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
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelScalingRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelScalingRatio);
		});
		elem.addEventListener("mouseup", (e:MouseEvent) -> {
			if (e.cancelable) e.preventDefault();
			switch (e.button) {
			case 0:
				nleft = false;
			case 1:
				nmiddle = false;
			case 2:
				nright = false;
			}
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelScalingRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelScalingRatio);
		});
		elem.addEventListener("mousemove", (e:MouseEvent) -> {
			nx = (e.clientX - elem.clientX()) * canvas.scaleX(input.scalingMode, pot.pixelScalingRatio);
			ny = (e.clientY - elem.clientY()) * canvas.scaleY(input.scalingMode, pot.pixelScalingRatio);
		});
		elem.addEventListener("contextmenu", (e:ContextEvent) -> {
			e.preventDefault();
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
	}

}
