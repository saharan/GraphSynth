package app;

import graph.Graph;
import graph.Node;
import js.html.CanvasElement;
import render.Renderer;

class NameEditControl extends MenuControl {
	var node:Node;
	var name:String;
	var getNextControl:Void->Control;
	var title:String;
	var onChange:String->Void;
	var maxLength:Int;
	var shiftPressed:Bool;

	public static function createNodeNameEdit(context:Context, node:Node, ?next:Void->Control):NameEditControl {
		return new NameEditControl(context, node, "Name", node.setting.name, 6, n -> node.setting.name = n,
			next != null ? next : () -> new NodeEditControl(context, node));
	}

	function new(context:Context, node:Node, title:String, initialValue:String, maxLength:Int, onChange:String->Void, getNextControl:Void->Control) {
		super(context);
		this.node = node;
		this.title = title;
		this.maxLength = maxLength;
		this.onChange = onChange;
		this.getNextControl = getNextControl;
		menu = new Menu(title, [
			["a", "b", "c", "d", "e"],
			["f", "g", "h", "i", "j"],
			["k", "l", "m", "n", "o"],
			["p", "q", "r", "s", "t"],
			["u", "v", "w", "x", "y"],
			["z", ".", "+", "-", "'"],
			["0", "1", "2", "3", "4"],
			["5", "6", "7", "8", "9"],
			["A/a", "BackSpace"],
		]);
		shiftPressed = false;
		menu.items.push(["close"]);
		name = initialValue;
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (focus != -1) {
			var str = "abcdefghijklmnopqrstuvwxyz.+-'0123456789SB";
			if (focus < str.length) {
				var command = str.charAt(focus);
				if (command == "S") {
					// shift
					shiftPressed = !shiftPressed;
					menu.items = menu.items.map(row -> row.map(s -> s.length == 1 ? shiftPressed ? s.toUpperCase() : s.toLowerCase() : s));
				} else if (command == "B") {
					// backspace
					if (name.length > 0) {
						name = name.substr(0, -1);
						onChange(name);
						if (node != null)
							node.notifyUpdate();
					}
				} else {
					if (name.length >= maxLength)
						name = name.substr(0, maxLength - 1);
					name += (s -> shiftPressed ? s.toUpperCase() : s.toLowerCase())(str.charAt(focus));
					onChange(name);
					if (node != null)
						node.notifyUpdate();
				}
			} else {
				nextControl = getNextControl();
			}
		}
	}

	override function step(x:Float, y:Float, touching:Bool) {
		menu.title = title + ":" + name;
		super.step(x, y, touching);
	}
}
