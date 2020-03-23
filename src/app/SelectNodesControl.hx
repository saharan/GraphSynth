package app;

import graph.Graph;
import graph.Node;
import graph.NodeSetting;
import graph.Vertex;
import js.html.CanvasElement;
import render.Renderer;

class SelectNodesControl extends Control {
	var pickRadius:Float;

	public function new(context:Context) {
		super(context);
		pickRadius = UISetting.tapErrorThreshold / renderer.view.scale;
	}

	override function onLongPress(x:Float, y:Float, tapCount:Int) {
		if (tapCount == 1) {
			var v:Vertex = graph.pick(x, y, Configurable, pickRadius);
			if (v == null) {
				nextControl = new ModuleCreationConfirmMenu(context);
			}
		}
	}

	override function onReleased(x:Float, y:Float, tapCount:Int) {
		if (tapCount == 1) {
			var v:Vertex = graph.pick(x, y, Node, pickRadius);
			if (v != null) {
				switch (v.type) {
					case Node(n):
						if (n.type.match(Boundary(_)) || n.setting.role.match(Destination)) {
							// cannot select node
						} else {
							n.selected = !n.selected;
							n.selectingCount = 0;
						}
					case _:
						throw "not a node";
				}
			}
		}
	}

	override function step(x:Float, y:Float, touching:Bool) {
		graph.stepPhysics();
		renderer.render(graph);
	}
}
