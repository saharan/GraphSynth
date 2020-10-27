package app.ui.view.menu.nodeedit;

import app.ui.core.layout.FlexLayout;
import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.menu.dialogue.Dialogue;
import app.ui.view.menu.dialogue.EditNameDialogue;
import app.ui.view.menu.nodeedit.NumberEditor;
import graph.Node;
import graph.serial.NodeFilter;
import pot.input.KeyValue;
import pot.input.Keyboard;
import synth.FilterType;
import synth.NodeRole;
import synth.OscillatorType;

using common.ArrayTools;
using common.FloatTools;
using common.IntTools;

class NodeEditMenu extends Menu {
	final node:Node;
	var updated:Bool;

	public function new(node:Node, graph:GraphWrapper) {
		super(graph);
		this.node = node;
		var op = graph.op;
		updated = false;

		enableClosingOnOutsideClick = true;

		addTitle("Edit Node");

		if (node.type.match(Module(_))) {
			addRow(item("go inside", () -> {
				op.gotoGraph(node.moduleGraph);
				graph.doneOperation(Goto);
			}, true));
			addRow(item(() -> "rename: " + node.setting.name, renameSetting.bind(node)));
			for (boundary in node.moduleBoundaries)
				addRow(item(() -> "rename param: " + boundary.setting.name, renameSetting.bind(boundary)));
			addRow(item("decompose", () -> {
				graph.raw.decomposeModule(node);
				graph.doneOperation(DecomposeModule);
			}, true));
			addSpace();
		}
		if (node.type.match(Boundary(_))) {
			addRow(item(() -> "rename: " + node.setting.name, renameSetting.bind(node)));
			addSpace();
		}

		switch node.setting.role {
			case Number(num):
				addNumberEditor("Value", "Value", num.value, Real, false, v -> num.value = v);
			case Envelope(env):
				addNumberEditor("A [sec]", "Attack", env.a, Sec, true, v -> env.a = v);
				addNumberEditor("D [sec]", "Decay", env.d, Sec, true, v -> env.d = v);
				addNumberEditor("S [lv] ", "Sustain", env.s, Level, true, v -> env.s = v);
				addNumberEditor("R [sec]", "Release", env.r, Sec, true, v -> env.r = v);
				addSpace();
			case Oscillator(type):
				addRoleEditor("wave type", ["sine", "sawtooth", "square", "triangle"], ["sin", "saw", "sq", "tri"],
					[Sine, Sawtooth, Square, Triangle], type, a -> Oscillator(a));
			case Filter(type):
				addRoleEditor("filter type", ["low pass", "high pass", "band pass", "band stop", "low shelf", "high shelf", "peak"],
					["LPF", "HPF", "BPF", "BSF", "LSF", "HSF", "PF"], [LowPass, HighPass, BandPass, BandStop, LowShelf, HighShelf, Peak],
					type, a -> Filter(a));
			case _:
		}

		if (!node.type.match(Boundary(_)) && !node.setting.role.match(Destination)) {
			addRow(item("remove", () -> {
				graph.raw.destroyNode(node);
				updated = true;
			}, true));
			addRow(item("copy", () -> {
				var data = graph.raw.serialize(NodeFilter.single(node), false);
				graph.op.copy(data);
			}, true));
		}
		addRow(item(() -> "close menu", null, true));

		primaryPointerDownOutsize = false;
	}

	override function onKeyboardUpdate(keyboard:Keyboard) {
		super.onKeyboardUpdate(keyboard);
		if (keyboard.isKeyDown(Enter))
			close();
	}

	override function onClose() {
		// check if the node is edited
		if (updated) {
			graph.doneOperation(NodeEdit);
		}
	}

	public static function createNameEditDialogue(graph:GraphWrapper, node:Node, onChange:Void->Void = null):Dialogue {
		return new EditNameDialog(graph, "", 8, name -> {
			if (name != null) {
				node.setting.name = name;
				node.notifyUpdate();
				if (onChange != null)
					onChange();
			}
		});
	}

	function renameSetting(node:Node):Void {
		graph.op.openMenu(createNameEditDialogue(graph, node, () -> updated = true));
	}

	function addRoleEditor<A>(title:String, descriptions:Array<String>, names:Array<String>, types:Array<A>, currentType:A,
			typeToRole:A->NodeRole):Void {
		var buttons = [];
		var n1 = descriptions.length;
		var n2 = names.length;
		var n3 = types.length;
		if (n1 != n2 || n1 != n3)
			throw "!?";
		for (i in 0...n1) {
			var b = radioButton(descriptions[i], () -> {
				node.setting.name = names[i];
				node.setting.role = typeToRole(types[i]);
				node.notifyUpdate();
				updated = true;
			}, currentType == types[i]);
			buttons.push(b);
		}
		var wrapper = new Sprite();
		wrapper.layout = new FlexLayout(Y);
		RadioButton.addGroup(buttons);
		for (b in buttons)
			wrapper.addChild(b);
		wrapper.style.grow = 1;
		addRow([label(title), wrapper], buttons.length);
	}

	function addNumberEditor(labelName:String, fullName:String, initial:Float, range:NumberRange, oneLine:Bool,
			onChanged:Float->Void):Void {
		new NumberEditor(graph, this, labelName, fullName, range, oneLine, initial, v -> {
			onChanged(v);
			updated = true;
			node.notifyUpdate();
		});
	}
}
