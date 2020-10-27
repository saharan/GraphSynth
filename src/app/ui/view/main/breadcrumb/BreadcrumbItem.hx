package app.ui.view.main.breadcrumb;

import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.main.breadcrumb.Breadcrumb.*;
import app.ui.view.menu.MenuItem;
import graph.Graph;
import graph.Node;

class BreadcrumbItem {
	public var button:Button;
	public var separator:Label;
	public var graph:Graph;
	public var inside:Node;

	var name:String;

	public function new(graphWrapper:GraphWrapper, graph:Graph) {
		this.graph = graph;

		inside = graph.parentModule;
		separator = inside == null ? null : new Label(">", Center, Px(16), Px(ITEM_HEIGHT), FONT_SIZE_SEPARATOR);
		button = new MenuItem(() -> name, () -> {
			if (graphWrapper.raw != graph) {
				graphWrapper.op.gotoGraph(graph);
				graphWrapper.doneOperation(Goto);
			}
		}, false);
		button.textScale = FONT_SIZE;
		updateName();
	}

	public function updateName():Void {
		name = inside == null ? "root" : inside.setting.name;
		button.style.size.set(Px(Font.measure(name) * FONT_SIZE), Px(ITEM_HEIGHT));
	}
}
