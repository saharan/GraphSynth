package app;

import graph.NodeSetting;
import graph.Graph;
import js.html.CanvasElement;
import render.Renderer;

class ModuleCreationConfirmMenu extends MenuControl {
	public function new(context:Context) {
		super(context);
		menu = new Menu("Menu", [["create module"], ["abort grouping"], ["end"]]);
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (focus != -1) {
			if (menu.items[focus][0] == "abort grouping") {
				for (n in graph.nodes) {
					n.selected = false;
					n.selectingCount = 0;
				}
				nextControl = new MainControl(context);
				return;
			}
			if (menu.items[focus][0] == "end") {
				nextControl = new SelectNodesControl(context);
				return;
			}
			if (menu.items[focus][0] == "create module") {
				var nodes = [];
				for (n in graph.nodes) {
					if (n.selected) {
						nodes.push(n);
						n.selected = false;
						n.selectingCount = 0;
					}
				}
				if (nodes.length != 0) {
					graph.createModule(nodes);
				}
				nextControl = new MainControl(context);
				return;
			}
		}
	}
}
