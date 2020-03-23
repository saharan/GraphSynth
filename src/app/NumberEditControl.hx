package app;

import graph.Node;
import synth.EnvelopeData;
import synth.NumberData;

private enum NumberType {
	Real;
	Time;
	Normalized;
}

class NumberEditControl extends MenuControl {
	var number:Float;
	var getNextControl:Void->Control;
	var offset:Array<Float>;
	var scale:Array<Float>;
	var title:String;
	var onChange:Float->Void;
	var min:Float;
	var max:Float;
	var node:Node;

	public static function createValueEdit(context:Context, node:Node, num:NumberData, ?next:Void->Control):NumberEditControl {
		var res = new NumberEditControl(context, node, "Value", num.value, n -> num.value = n, next != null ? next : () -> new MainControl(context), Real);
		// this is ridiculous, must improve later
		res.menu.items.insert(-1, []);
		res.menu.items.insert(-1, ["remove"]);
		res.menu.items.insert(-1, ["copy"]);
		return res;
	}

	public static function createAttackEdit(context:Context, node:Node, env:EnvelopeData, ?next:Void->Control):NumberEditControl {
		return new NumberEditControl(context, node, "Attack", env.a, n -> env.a = n, next != null ? next : () -> new NodeEditControl(context, node), Time);
	}

	public static function createDecayEdit(context:Context, node:Node, env:EnvelopeData, ?next:Void->Control):NumberEditControl {
		return new NumberEditControl(context, node, "Decay", env.d, n -> env.d = n, next != null ? next : () -> new NodeEditControl(context, node), Time);
	}

	public static function createSustainEdit(context:Context, node:Node, env:EnvelopeData, ?next:Void->Control):NumberEditControl {
		return new NumberEditControl(context, node, "Sustain", env.s, n -> env.s = n, next != null ? next : () -> new NodeEditControl(context, node),
			Normalized);
	}

	public static function createReleaseEdit(context:Context, node:Node, env:EnvelopeData, ?next:Void->Control):NumberEditControl {
		return new NumberEditControl(context, node, "Release", env.r, n -> env.r = n, next != null ? next : () -> new NodeEditControl(context, node), Time);
	}

	function new(context:Context, node:Node, title:String, initialValue:Float, onChange:Float->Void, getNextControl:Void->Control, type:NumberType) {
		super(context);
		this.node = node;
		this.title = title;
		this.onChange = onChange;
		this.getNextControl = getNextControl;
		var labels;
		switch (type) {
			case Real:
				offset = [100, -100, 10, -10, 1, -1, 0.1, -0.1, 0.01, -0.01, 0, 0, 0, 0];
				scale = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 0.1, 0, -1];
				labels = [
					["+100", "-100"],
					["+10", "-10"],
					["+1", "-1"],
					["+0.1", "-0.1"],
					["+0.01", "-0.01"],
					["×10", "÷10"],
					["0", "+/-"],
				];
				min = -10000;
				max = 10000;
			case Time:
				offset = [1, -1, 0.1, -0.1, 0.01, -0.01, 0.001, -0.001, 0, 0, 0];
				scale = [1, 1, 1, 1, 1, 1, 1, 1, 10, 0.1, 0];
				labels = [
					["+1", "-1"],
					["+0.1", "-0.1"],
					["+0.01", "-0.01"],
					["+0.001", "-0.001"],
					["×10", "÷10"],
					["0"],
				];
				min = 0;
				max = 10;
			case Normalized:
				offset = [0.1, -0.1, 0.01, -0.01, 0.001, -0.001, 0, 0, 0, 1];
				scale = [1, 1, 1, 1, 1, 1, 10, 0.1, 0, 0];
				labels = [
					["+0.1", "-0.1"],
					["+0.01", "-0.01"],
					["+0.001", "-0.001"],
					["×10", "÷10"],
					["0", "1"],
				];
				min = 0;
				max = 1;
		}
		menu = new Menu(title, labels);
		menu.items.push(["close"]);
		number = initialValue;
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (focus != -1) {
			if (focus < offset.length) {
				number = number * scale[focus] + offset[focus];
				number = number < min ? min : number > max ? max : number;
				var intNumber = Math.round(number * 10000);
				if (intNumber == 0 && number != 0)
					intNumber = number > 0 ? 1 : -1;
				number = intNumber / 10000;
				onChange(number);
				if (node != null)
					node.notifyUpdate();
			} else {
				if (Lambda.flatten(menu.items)[focus] == "remove") {
					graph.destroyNode(node);
				}
				if (Lambda.flatten(menu.items)[focus] == "copy") {
					context.clipboard.copyNode(node);
				}
				nextControl = getNextControl();
			}
		}
	}

	override function step(x:Float, y:Float, touching:Bool) {
		menu.title = title + ":" + number;
		super.step(x, y, touching);
	}
}
