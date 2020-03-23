package app;

import synth.FilterType;
import graph.NodeOption;
import synth.OscillatorType;
import graph.Graph;
import graph.Node;
import render.Renderer;
import synth.EnvelopeData;
import synth.NodeRole;
import synth.NumberData;

private enum Action {
	LookInside(g:Graph);
	Decompose;
	EditVal(num:NumberData);
	EditName();
	EditBoundaryName(boundary:Node);
	EditA(env:EnvelopeData);
	EditD(env:EnvelopeData);
	EditS(env:EnvelopeData);
	EditR(env:EnvelopeData);
	Remove;
	Copy;
	None;
}

class NodeEditControl extends MenuControl {
	var atX:Float;
	var atY:Float;

	var node:Node;

	var options:Array<NodeOption>;

	var action:Action;

	public function new(context:Context, node:Node) {
		super(context);
		this.node = node;
		var options = [];
		if (node.type.match(Module(_))) {
			options.push(new NodeOption(_ -> "look inside", _ -> action = LookInside(node.moduleGraph), true));
			options.push(new NodeOption(_ -> "edit name:" + node.setting.name, _ -> action = EditName));
			for (boundary in node.moduleBoundaries) {
				options.push(new NodeOption(_ -> "edit param name:" + boundary.setting.name, _ -> action = EditBoundaryName(boundary)));
			}
			options.push(new NodeOption(_ -> "decompose", _ -> action = Decompose, true));
			options.push(null);
		}
		if (node.type.match(Boundary(_))) {
			options.push(new NodeOption(_ -> "edit name:" + node.setting.name, _ -> action = EditName));
			options.push(null);
		}
		switch (node.setting.role) {
			case Number(num):
				options.push(new NodeOption(_ -> "edit value", _ -> action = EditVal(num)));
				options.push(null);
			case Envelope(env):
				options.push(new NodeOption(_ -> "edit Attack:" + env.a, _ -> action = EditA(env)));
				options.push(new NodeOption(_ -> "edit Decay:" + env.d, _ -> action = EditD(env)));
				options.push(new NodeOption(_ -> "edit Sustain:" + env.s, _ -> action = EditS(env)));
				options.push(new NodeOption(_ -> "edit Release:" + env.r, _ -> action = EditR(env)));
				options.push(null);
			case Oscillator(_):
				var items = ["sine", "sawtooth", "square", "triangle"].map(s -> s + " wave");
				var names = ["sin", "saw", "sq", "tri"];
				var types:Array<OscillatorType> = [Sine, Sawtooth, Square, Triangle];
				for (i in 0...items.length) {
					options.push(new NodeOption(_ -> items[i], n -> {
						n.name = names[i];
						n.role = Oscillator(types[i]);
					}));
				}
				options.push(null);
			case Filter(_):
				var items = [
					"low pass",
					"high pass",
					"band pass",
					"band stop",
					"low shelf",
					"high shelf",
					"peak"
				].map(s -> s + " filter");
				var names = ["LPF", "HPF", "BPF", "BSF", "LSF", "HSF", "PF"];
				var types:Array<FilterType> = [LowPass, HighPass, BandPass, BandStop, LowShelf, HighShelf, Peak];
				for (i in 0...items.length) {
					options.push(new NodeOption(_ -> items[i], n -> {
						n.name = names[i];
						n.role = Filter(types[i]);
					}));
				}
				options.push(null);
			case _:
		}
		if (!node.type.match(Boundary(_)) && !node.setting.role.match(Destination)) {
			options.push(new NodeOption(_ -> "remove", _ -> action = Remove, true));
			options.push(new NodeOption(_ -> "copy", _ -> action = Copy, true));
		}
		options.push(new NodeOption(_ -> "close", _ -> action = None, true));
		menu = new Menu("Edit Node", options.map(o -> o == null ? [] : [""]));
		this.options = options.filter(o -> o != null);
		action = None;
	}

	function newControl():NodeEditControl {
		return new NodeEditControl(context, node);
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (focus != -1) {
			var option = options[focus];
			option.onSelected(node);
			switch (action) {
				case LookInside(g):
					graph.bakeView(renderer.view);
					nextControl = new MainControl(context.changeGraph(g));
				case EditName:
					nextControl = NameEditControl.createNodeNameEdit(context, node);
				case EditBoundaryName(boundary):
					// should back to edit of `node`, not `boundary`
					nextControl = NameEditControl.createNodeNameEdit(context, boundary, newControl);
				case Decompose:
					graph.decomposeModule(node);
				case Copy:
					context.clipboard.copyNode(node);
				case EditVal(num):
					nextControl = NumberEditControl.createValueEdit(context, node, num);
				case EditA(env):
					nextControl = NumberEditControl.createAttackEdit(context, node, env);
				case EditD(env):
					nextControl = NumberEditControl.createDecayEdit(context, node, env);
				case EditS(env):
					nextControl = NumberEditControl.createSustainEdit(context, node, env);
				case EditR(env):
					nextControl = NumberEditControl.createReleaseEdit(context, node, env);
				case Remove:
					graph.destroyNode(node);
				case None:
			}
			if (nextControl == null && option.closeAfterSelection)
				nextControl = new MainControl(context);
		}
	}

	override function step(x:Float, y:Float, touching:Bool) {
		menu.title = "Edit Node:" + switch (node.setting.role) {
			case Number(num): Std.string(num.value);
			case _: node.setting.name;
		};
		var idx = 0;
		for (o in options) {
			while (menu.items[idx].length == 0) {
				idx++;
			}
			menu.items[idx++][0] = o.name(node.setting);
		}
		super.step(x, y, touching);
	}
}
