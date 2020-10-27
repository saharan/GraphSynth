package app.ui.view.menu.dialogue;

import app.ui.view.main.graph.GraphWrapper;
import pot.input.KeyValue;
import pot.input.Keyboard;

using common.FloatTools;

class CalcEnterDialog extends Dialogue {
	var value:Float;
	var str:String;
	var confirmed:Bool;

	public function new(graph:GraphWrapper, name:String, onClose:Null<Float>->Void) {
		super(graph, () -> onClose(confirmed ? value : null));
		str = "0";
		confirmed = false;
		value = 0;

		addTitle("Edit:" + name);
		addRow(label(() -> str, 1.5));
		addSpace();

		wrapper.style.padding.setAlong(X, Px(16), Px(16));
		var rows:Array<Array<Sprite>> = [];
		var zero;
		rows.push([button("Clear", clear), button("BackSpace", backspace), button("+/-", changeSign)]);
		for (nums in [[7, 8, 9], [4, 5, 6], [1, 2, 3]]) {
			rows.push(nums.map(n -> (button(Std.string(n), addNum.bind(n)) : Sprite)));
		}
		rows.push([zero = button("0", () -> addNum(0)), button(".", addPoint)]);
		zero.style.grow = 2;
		for (row in rows) {
			for (b in row)
				b.style.size.h = Auto;
			addRow(row, 1.4);
		}
		addSpace();
		addRow([item("Cancel", null, true), item("OK", () -> confirmed = true, true)]);
	}

	function clear():Void {
		str = "0";
		value = 0;
	}

	function changeSign():Void {
		str = str.charAt(0) == "-" ? str.substr(1) : "-" + str;
		updateValue();
	}

	function backspace():Void {
		if (str == "-0") {
			str = "0";
		} else {
			str = str.substr(0, str.length - 1);
			if (str == "" || str == "-")
				str += "0";
		}
		updateValue();
	}

	function addPoint():Void {
		if (str.indexOf(".") == -1)
			str += ".";
		updateValue();
	}

	function addNum(n:Int):Void {
		if (str == "0" || str == "-0")
			str = str.substr(0, str.length - 1);
		var maxLen = 9 + (str.indexOf("-") != -1 ? 1 : 0) + (str.indexOf(".") != -1 ? 1 : 0);
		if (str.length < maxLen) {
			str += n;
		}
		updateValue();
	}

	function updateValue():Void {
		value = Std.parseFloat(str);
		value = value.clamp(-10000, 10000);
		var vi = Math.round(value * 10000);
		if (vi == 0 && value != 0)
			vi = value > 0 ? 1 : -1;
		value = vi / 10000;
	}

	override function onKeyboardUpdate(keyboard:Keyboard) {
		super.onKeyboardUpdate(keyboard);
		graph.op.getKeyboard().forEachDownKey(key -> {
			switch key {
				case Backspace:
					backspace();
				case Enter:
					confirmed = true;
					close();
				case "-":
					changeSign();
				case ".":
					addPoint();
				case _:
					if (KeyValue.DIGITS.contains(key)) {
						addNum(key.charCodeAt(0) - "0".charCodeAt(0));
					}
			}
		});
	}
}
