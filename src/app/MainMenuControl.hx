package app;

import graph.NodeSetting;

class MainMenuControl extends MenuControl {
	var nodes:Array<NodeInfo>;
	var atX:Float;
	var atY:Float;
	var flatItems:Array<String>;

	public function new(context:Context, atX:Float, atY:Float) {
		super(context);
		this.atX = atX;
		this.atY = atY;
		var nodes2 = [
			[NodeList.OSCILLATOR],
			[NodeList.DELAY],
			[NodeList.FILTER],
			[NodeList.COMPRESSOR],
			[NodeList.FREQUENCY],
			[NodeList.ENVELOPE],
			[NodeList.NUMBER],
		];
		nodes = Lambda.flatten(nodes2);
		if (graph.parent != null)
			nodes.remove(NodeList.OUTPUT);
		menu = new Menu("Menu", nodes2.map(nodes -> nodes.map(n -> n == null ? null : "add " + n.fullName)));
		if (context.clipboard.hasData())
			menu.items.push(["paste"]);
		menu.items.push([]);
		menu.items.push(["create module"]);
		if (graph.parent == null) {
			// menu.items.push(["save graph", "load graph"]);
		} else {
			menu.items.push(["exit module"]);
		}
		menu.items.push(["reset view"]);
		menu.items.push(["close"]);
		flatItems = Lambda.flatten(menu.items);
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (focus != -1) {
			if (flatItems[focus] == "reset view") {
				var main = new MainControl(context);
				main.centering();
				nextControl = main;
				return;
			}
			if (flatItems[focus] == "close") {
				nextControl = new MainControl(context);
				return;
			}
			if (flatItems[focus] == "exit module") {
				graph.bakeView(renderer.view);
				nextControl = new MainControl(context.changeGraph(graph.parent));
				return;
			}
			if (flatItems[focus] == "paste") {
				context.clipboard.pasteNode(graph, atX, atY);
				nextControl = new MainControl(context);
				return;
			}
			if (flatItems[focus] == "create module") {
				nextControl = new SelectNodesControl(context);
				return;
			}
			var node = nodes[focus].create(graph, atX, atY);
			nextControl = switch (node.setting.role) {
				case Number(num): NumberEditControl.createValueEdit(context, node, num);
				case _: new MainControl(context);
			}
		}
	}
}
