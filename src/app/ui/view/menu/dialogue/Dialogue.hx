package app.ui.view.menu.dialogue;

import app.ui.view.main.graph.GraphWrapper;

class Dialogue extends Menu {
	final callback:Void->Void;

	public function new(graph:GraphWrapper, onClose:Void->Void) {
		super(graph, new DialogueWindow());
		this.callback = onClose;
		wrapper.style.margin.setAlong(Y, Auto, Auto);
		wrapper.style.minSize.h = Px(Menu.ITEM_HEIGHT * 5);

		enableClosingOnOutsideClick = true;

		// extend bottom margin
		var glue = new Sprite();
		glue.style.margin.bottom = Auto;
		addChild(glue);
	}

	override function onClose() {
		if (callback != null)
			callback();
	}
}
