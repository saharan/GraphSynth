package app.ui.view;

import app.graphics.Graphics;
import app.ui.core.layout.Axis;

using common.FloatTools;

enum SliderType {
	Linear;
	Logarithmic(power:Int);
	BiLogarithmic(power:Int);
}

class Slider extends Sprite {
	var axis:Axis;

	public var rawRatio:Float;
	public var ratio:Float;
	public var value(default, null):Float;
	public var margin:Float;
	public var min:Float;
	public var max:Float;

	public var onUpdate:Float->Void;

	var type:SliderType;
	var over:Bool = false;
	var grabbed:Pointer = null;

	public function new(axis:Axis, min:Float, max:Float, initial:Float, type:SliderType, onUpdate:Float->Void) {
		super();
		this.axis = axis;
		this.type = type;
		this.min = min;
		this.max = max;
		this.onUpdate = onUpdate;
		stopEvent = true;
		pointerPolicy = Exclusive;
		setValue(initial);
		margin = 8;
	}

	public function setValue(v:Float):Void {
		if (value == v)
			return;
		value = v;
		ratio = (value - min) / (max - min);
		rawRatio = invMapRatio(ratio).clamp(0, 1);
		if (!Math.isFinite(rawRatio))
			rawRatio = 0;
		onUpdate(value);
	}

	override function onPointerEnter(p:Pointer) {
		if (p.isPrimary)
			over = true;
	}

	override function onPointerExit(p:Pointer) {
		if (p.isPrimary)
			over = false;
	}

	override function onPointerDown(p:Pointer, index:Int) {
		if (p.isPrimary && index == 0)
			grabbed = p;
	}

	override function onPointerUp(p:Pointer, index:Int) {
		if (grabbed == p && index == 0)
			grabbed = null;
	}

	override function update() {
		if (grabbed != null) {
			var start = margin;
			var end = element.boundary.size(axis) - margin;
			var pos = axis == X ? grabbed.x : grabbed.y;
			rawRatio = ((pos - start) / (end - start)).clamp(0, 1);
			if (!Math.isFinite(rawRatio))
				rawRatio = 0;
			ratio = mapRatio(rawRatio);
			setValue(min + (max - min) * ratio);
		}
	}

	function mapRatio(r:Float):Float {
		return switch type {
			case Linear:
				r;
			case Logarithmic(power):
				mapExp(r, power);
			case BiLogarithmic(power):
				var t = r * 2 - 1;
					(t < 0 ? -mapExp(-t, power) : mapExp(t, power)) * 0.5 + 0.5;
		}
	}

	function invMapRatio(r:Float):Float {
		return switch type {
			case Linear:
				r;
			case Logarithmic(power):
				mapLog(r, power);
			case BiLogarithmic(power):
				var t = r * 2 - 1;
					(t < 0 ? -mapLog(-t, power) : mapLog(t, power)) * 0.5 + 0.5;
		}
	}

	function mapExp(r:Float, power:Float):Float {
		var min = 1;
		var max = pow2(power);
		return (pow2(r * power) - min) / (max - min);
	}

	function mapLog(r:Float, power:Float):Float {
		var min = 1;
		var max = pow2(power);
		return log2(r * (max - min) + min) / power;
	}

	extern static inline function pow2(a:Float):Float
		return Math.pow(2, a);

	extern static inline function log2(a:Float):Float
		return Math.log(a) / Math.log(2);

	override function draw(g:Graphics) {
		var start = margin;
		var end = element.boundary.size(axis) - margin;
		var pos = start + rawRatio * (end - start);
		var baseline = axis == X ? height * 0.5 : width * 0.5;
		var zeroRawRatio = invMapRatio((0 - min) / (max - min)).clamp(0, 1);
		var zeroPos = start + zeroRawRatio * (end - start);
		if (over) {
			g.fill(0.6, 0, 0);
		} else {
			g.fill(0, 0, 0);
		}
		var r = grabbed != null ? 8 : 6;
		g.stroke(0.75, 0.75, 0.75);
		g.lineWidth(3);
		g.lineCap(Round);
		switch axis {
			case X:
				g.line(start, baseline, end, baseline);

				g.lineWidth(4);
				g.stroke(0, 0, 0);
				g.line(start, baseline, pos, baseline);
				g.circle(pos, baseline, r, Fill);
			case Y:
				g.line(baseline, start, baseline, end);

				g.lineWidth(4);
				g.stroke(0, 0, 0);
				g.line(baseline, start, baseline, pos);
				g.circle(baseline, pos, r, Fill);
		}
	}
}
