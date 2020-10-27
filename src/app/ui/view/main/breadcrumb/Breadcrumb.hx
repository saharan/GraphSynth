package app.ui.view.main.breadcrumb;

import app.ui.core.layout.FlexLayout;
import app.ui.view.main.graph.GraphWrapper;
import graph.Graph;
import graph.Node;
import graph.NodeUpdateListener;

class Breadcrumb extends Sprite implements NodeUpdateListener {
	public static inline final ITEM_HEIGHT:Float = 16;
	public static inline final FONT_SIZE:Float = 1.1;
	public static inline final FONT_SIZE_SEPARATOR:Float = 1.0;

	final graph:GraphWrapper;
	final items:Array<BreadcrumbItem> = [];

	public function new(graph:GraphWrapper) {
		super();
		this.graph = graph;
		style.boxSizing = Boundary;
		style.margin.top = Px(36);
		style.padding.left = Px(8);
		style.padding.right = Px(8);
		layout = new FlexLayout(X);
		stopEvent = true;
		updatePath();
	}

	function push(g:Graph):Void {
		var item = new BreadcrumbItem(graph, g);
		items.push(item);
		if (item.separator != null)
			addChild(item.separator);
		addChild(item.button);
	}

	public function updatePath():Void {
		// check if items can be reused
		while (items.length > 0) {
			var item = items.pop();
			if (item.graph == graph.raw) {
				items.push(item);
				return;
			}
			item.button.dead = true;
			if (item.separator != null)
				item.separator.dead = true;
		}

		// reconstruct all items
		var path = graph.raw.getPath();
		for (g in path) {
			push(g);
		}
	}

	public function onNodeUpdate(node:Node):Void {
		for (item in items) {
			item.updateName();
		}
	}
}
