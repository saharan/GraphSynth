package app.ui.view.menu.dialogue;

import app.ui.view.main.graph.GraphWrapper;
import pot.input.KeyValue;
import pot.input.Keyboard;

class EditNameDialog extends Dialogue {
	final allChars:Array<String>;
	final maxLength:Int;
	var name:String;
	var confirmed:Bool = false;
	var upper:Bool = false;
	var count:Int = 0;

	public function new(graph:GraphWrapper, initial:String, maxLength:Int, onClose:String->Void) {
		super(graph, () -> {
			onClose(confirmed ? name : null);
		});
		this.maxLength = maxLength;
		name = initial;

		addTitle("Edit Name");
		addRow(label(() -> name + ((count = ++count & 63) & 16 == 0 ? "_" : " "), 1.5));
		addSpace();

		wrapper.style.padding.setAlong(X, Px(16), Px(16));
		var rows = [];
		var lines = ["abcdef", "ghijkl", "mnopqr", "stuvwx", "yz+-()", "012345", "6789.,"];
		allChars = lines.join("").split("");
		for (line in lines) {
			var row = [];
			for (i in 0...line.length) {
				var char = line.charAt(i);
				var getChar = () -> upper ? char.toUpperCase() : char;
				var item = item(getChar, () -> add(getChar()), false, false);
				item.textScale *= 1.2;
				item.style.size.h = Auto;
				row.push(item);
			}
			rows.push(row);
		}
		for (row in rows) {
			addRow(row, 1.2);
		}
		addSpace();
		addRow([button("Clear", clear), button("BackSpace", backspace), button("A/a", () -> upper = !upper)]);
		addSpace();
		addRow([item("Cancel", null, true), item("OK", () -> confirmed = true, true)]);
	}

	function clear():Void {
		name = "";
	}

	function backspace():Void {
		if (name.length > 0)
			name = name.substr(0, name.length - 1);
	}

	function add(char:String):Void {
		var max = maxLength - 1;
		if (name.length > max)
			name = name.substring(0, max);
		name += char;
	}

	override function onKeyboardUpdate(keyboard:Keyboard) {
		super.onKeyboardUpdate(keyboard);
		keyboard.forEachDownKey(key -> {
			switch key {
				case Backspace:
					backspace();
				case Enter:
					confirmed = true;
					close();
				case _:
					if (allChars.contains(key.toLowerCase())) {
						add(key);
					}
			}
		});
	}
}
