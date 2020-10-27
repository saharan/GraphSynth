package app.ui.view.main.graph;

import app.NodeInfo;
import app.ui.view.main.graph.drag.DragHandler;

enum ClickState {
	Idle;
	ClickOn(target:ClickTarget);
	Dragging(handler:DragHandler);
	Trailing;
}
