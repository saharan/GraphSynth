package app.ui.view.main;

import app.ui.view.menu.example.OpenExamplesMenu;
import graph.Graph;
import graph.serial.GraphData;
import app.ui.core.layout.FlexLayout;
import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.menu.pulldown.PulldownMenu;
import graph.serial.NodeFilter;

class Toolbar extends Sprite {
	final graph:GraphWrapper;
	final pulldownMenues:Array<PulldownMenu>;

	public function new(graph:GraphWrapper) {
		super();
		this.graph = graph;
		var op = graph.op;

		style.boxSizing = Boundary;
		style.size.set(Percent(100), Percent(100));
		style.padding.all(Px(2));

		var fl = new FlexLayout(Y);
		layout = fl;

		var bottom = new Sprite();
		bottom.layout = new FlexLayout(X);
		bottom.style.margin.top = Auto;

		bottom.addChild(new Button(Px(20), Px(20), "-", op.changeOctave.bind(-1)));
		bottom.addChild(new Button(Px(20), Px(20), "+", op.changeOctave.bind(1)));
		for (c in bottom.children) {
			c.style.margin.all(Px(2));
		}

		var top = new Sprite();
		top.layout = new FlexLayout(X);

		var nodeNames = ["Oscillator", "Delay", "Filter", "Compressor", "Frequency", "Envelope", "Number"];
		var nodeInfos = [NodeList.OSCILLATOR, NodeList.DELAY, NodeList.FILTER, NodeList.COMPRESSOR, NodeList.FREQUENCY, NodeList.ENVELOPE, NodeList.NUMBER];

		pulldownMenues = [];

		top.addChild(pulldownMenu("Data", ["New Graph", "Examples", "Load", "Save"], [clearGraph, openExample, importGraph, exportGraph],
			pulldownMenues));
		top.addChild(pulldownMenu("New", nodeNames, [for (i in 0...nodeNames.length) {
			() -> {
				op.selectNodeCreation(nodeInfos[i]);
				closeAll();
			}
		}], pulldownMenues));
		top.addChild(pulldownMenu("Edit", ["Undo", "Redo", "Cut", "Copy", "Paste", "Remove"],
			[undo, redo, cut.bind(true), copy.bind(true), paste.bind(true), remove.bind(true)], pulldownMenues));
		top.addChild(pulldownMenu("Module", ["Create", "Decompose", "Import", "Export"],
			[createModule.bind(true), decomposeModule.bind(true), importModule, exportModule], pulldownMenues));

		for (c in top.children) {
			c.style.margin.all(Px(2));
		}

		addChild(top);
		addChild(bottom);
	}

	function clearGraph():Void {
		if (graph.lastOperation == Reset && !graph.canRedo())
			return;
		graph.op.reset();
		graph.doneOperation(Reset);
	}

	function openExample():Void {
		graph.op.openMenu(new OpenExamplesMenu(graph));
		closeAll();
	}

	function importGraph():Void {
		switch graph.op.importGraph() {
			case Succeeded:
				graph.op.showInfo("Loaded!", Info);
				graph.doneOperation(Import);
				closeAll();
			case Failed:
				closeAll();
			case Cancelled:
		}
	}

	function exportGraph():Void {
		exportData(graph.raw.serialize(NodeFilter.ALL, false));
		closeAll();
	}

	function importModule():Void {
		switch graph.op.importModule() {
			case Succeeded:
				closeAll();
			case Failed:
				closeAll();
			case Cancelled:
		}
	}

	function exportModule():Void {
		var data = graph.selection.createSubgraphData(true);
		if (data.nodes.length > 0) {
			exportData(data);
			closeAll();
		} else {
			graph.op.showInfo("Select nodes to export.", Warning);
		}
	}

	function exportData(data:GraphData):Void {
		var g = Graph.deserialize(data);
		g.moveCenterToZero();
		graph.op.exportData(g.serialize(NodeFilter.ALL, false));
	}

	public function createModule(closeWhenDone:Bool):Void {
		if (!graph.createModuleWithCurrentSelection())
			return;
		graph.doneOperation(CreateModule);
		if (closeWhenDone)
			closeAll();
	}

	public function decomposeModule(closeWhenDone:Bool):Void {
		var modules = graph.selection.toArray().filter(n -> n.type.match(Module(_, _)));
		if (modules.length > 0) {
			graph.decomposeModules(modules);
			graph.doneOperation(DecomposeModule);
			if (closeWhenDone)
				closeAll();
		} else {
			graph.op.showInfo("Select modules to decompose.", Warning);
		}
	}

	public function undo():Void {
		if (!graph.canUndo())
			return;
		graph.undo();
	}

	public function redo():Void {
		if (!graph.canRedo())
			return;
		graph.redo();
	}

	public function cut(closeWhenDone:Bool):Void {
		if (!copySelectedSubGraph())
			return;
		if (!removeSelectedSubGraph())
			return;
		graph.doneOperation(Cut);
		if (closeWhenDone)
			closeAll();
	}

	public function copy(closeWhenDone:Bool):Void {
		if (!copySelectedSubGraph())
			return;
		if (closeWhenDone)
			closeAll();
	}

	public function remove(closeWhenDone:Bool):Void {
		if (!removeSelectedSubGraph())
			return;
		graph.doneOperation(Remove);
		if (closeWhenDone)
			closeAll();
	}

	public function paste(closeWhenDone:Bool):Void {
		if (graph.op.paste()) {
			if (closeWhenDone)
				closeAll();
		}
	}

	public function selectAll(closeWhenDone:Bool):Void {
		graph.selection.clear();
		for (node in graph.nodes) {
			graph.selection.add(node);
		}
		if (closeWhenDone)
			closeAll();
	}

	function removeSelectedSubGraph():Bool {
		var res = graph.destroyNodes(graph.selection.toArray().filter(graph.canDestroyNode));
		graph.selection.clear();
		return res;
	}

	function copySelectedSubGraph():Bool {
		if (graph.selection.count() < 1)
			return false;
		var data = graph.selection.createSubgraphData(true);
		if (data.nodes.length < 1)
			return false;
		graph.op.copy(data);
		return true;
	}

	function pulldownMenu(name:String, children:Array<String>, onChildrenClicks:Array<Void->Void>, menuList:Array<PulldownMenu>):Sprite {
		var menuWidth = 60;
		var buttonHeight = 24;
		var fontScale = 1.0;
		var wrapper = new Sprite();
		wrapper.layout = new FlexLayout(Y);
		var menu = new PulldownMenu();
		menuList.push(menu);
		menu.layout = new FlexLayout(Y);
		var button = new Button(Px(menuWidth), Px(buttonHeight), name, () -> {
			if (menu.isShown())
				menu.hide();
			else {
				menu.show();
				// close other menues
				for (m in menuList) {
					if (m != menu)
						m.hide();
				}
			}
		}, fontScale);
		button.style.margin.bottom = Px(2);
		var extraWidth = 30;
		for (i in 0...children.length) {
			var item = new Button(Px(menuWidth + extraWidth), Px(buttonHeight), children[i], onChildrenClicks[i], fontScale);
			item.style.margin.right = Px(-extraWidth);
			item.style.margin.bottom = Px(2);
			menu.addChild(item);
		}
		wrapper.addChild(button);
		wrapper.addChild(menu);
		return wrapper;
	}

	public function closeAll():Void {
		for (menu in pulldownMenues) {
			menu.hide();
		}
	}
}
