package app.ui.view.menu.example;

import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.menu.dialogue.SelectItemDialogue;
import common.Pair;

class OpenExamplesMenu extends Menu {
	public function new(graph:GraphWrapper) {
		super(graph);
		enableClosingOnOutsideClick = true;
		addTitle("Select Examples");
		init();
	}

	public function init():Void {
		showCategories();
	}

	function showCategories():Void {
		for (cat in ExampleList.getExamples()) {
			addRow([item(cat.name, openCategory.bind(cat))]);
		}
	}

	function openCategory(cat:ExampleCategory):Void {
		graph.op.openMenu(new SelectItemDialogue(graph, ex -> {
			if (ex != null)
				loadExample(ex);
		}, cat.name, cat.examples.map(ex -> Pair.of(ex.name, ex))));
	}

	function loadExample(ex:Example):Void {
		graph.op.loadAsRoot(ex.data, true);
		graph.doneOperation(Import);
		close();
	}
}
