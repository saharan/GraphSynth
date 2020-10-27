package app.ui.view.menu.dialogue;

import app.ui.view.main.graph.GraphWrapper;
import common.Pair;

class SelectItemDialogue<A> extends Dialogue {
	var selected:Null<A>;

	public function new(graph:GraphWrapper, onClose:Null<A>->Void, title:String, items:Array<Pair<String, A>>) {
		super(graph, () -> onClose(selected));
		addTitle(title);
		addSpace();
		selected = null;
		for (item in items)
			addRow(this.item(item.a, () -> selected = item.b, true));
	}
}
