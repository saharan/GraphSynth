package app.ui.view.main;

import pot.input.KeyValue;
import graph.serial.NodeFilter;
import graph.serial.GraphData;
import app.graphics.Graphics;
import app.ui.core.layout.OverlayLayout;
import app.ui.view.color.DynamicColor;
import app.ui.view.main.breadcrumb.Breadcrumb;
import app.ui.view.main.graph.ClickController;
import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.main.input.InputController;
import graph.Graph;
import render.View;

class MainSprite extends Sprite {
	final waveData:Array<Float> = [];
	final graph:GraphWrapper;
	final renderer:GraphRenderer;
	final toolbar:Toolbar;
	final breadcrumb:Breadcrumb;
	final clipboard:Clipboard;

	final inputController:InputController;
	final viewController:ViewController;
	final clickController:ClickController;

	final initialGraph:GraphData;

	var infoText:String = "";
	var infoLabel:Label;

	public function new(graph:Graph, op:MainOperator) {
		super();
		this.graph = new GraphWrapper(graph, new View(element.boundary), op);
		renderer = new GraphRenderer(waveData);

		style.maxSize.w = Percent(100);
		style.grow = 1;
		layout = new OverlayLayout();

		breadcrumb = new Breadcrumb(this.graph);
		addChild(breadcrumb);

		toolbar = new Toolbar(this.graph);
		addChild(toolbar);

		clipboard = new Clipboard();

		inputController = new InputController();
		pointerManager.addListener(inputController);

		viewController = new ViewController(this.graph.view);
		inputController.addListener(viewController);

		clickController = new ClickController(this.graph);
		inputController.addListener(clickController);

		infoText = "";
		infoLabel = new Label(() -> infoText, Right, Percent(80), Px(16), 1.1);
		infoLabel.style.boxSizing = Boundary;
		infoLabel.style.margin.set(Auto, Auto, Px(8), Px(8));
		addChild(infoLabel);

		initialGraph = createInitialGraphData();

		resetGraph();

		// set the first undoable point
		this.graph.doneOperation(Reset);
	}

	public function resetGraph():Void {
		loadAsRoot(initialGraph, true);
	}

	static function createInitialGraphData():GraphData {
		var g = new Graph();
		var output = NodeList.OUTPUT.create(g, 80, 0, false);

		var x = -20.0;
		var y = 0.0;
		var oscillator = NodeList.OSCILLATOR.create(g, x, y, false);
		var r = 80.0;

		for (s in oscillator.sockets) {
			var ang = s.phys.getAngle();
			switch s.type {
				case Param(_, name):
					var info = switch name {
						case "freq":
							NodeList.FREQUENCY;
						case "gain":
							NodeList.ENVELOPE;
						case "detune":
							NodeList.numberOfValue(0);
						case _:
							null;
					}
					if (info != null) {
						var node = info.create(g, x + r * Math.cos(ang), y + r * Math.sin(ang), false);
						g.connectVertices(node.phys.vertex, s.phys.vertex);
					}
				case _:
			}
		}

		g.connectVertices(oscillator.phys.vertex, output.phys.vertex);
		return g.serialize(NodeFilter.ALL, false);
	}

	public function selectNodeCreation(n:NodeInfo):Void {
		clickController.click.gotoNodeCreationMode(n);
	}

	public function closeToolbar():Void {
		toolbar.closeAll();
	}

	public function showInfo(text:String, type:InfoType):Void {
		infoText = text;

		infoLabel.fillColor = switch type {
			case Persistent:
				DynamicColor.sine([0, 0, 0, 1], [0, 0, 0, 0.3], 1);
			case Info:
				DynamicColor.fade([0, 0, 0, 1], 3, 1);
			case Warning:
				DynamicColor.fade([0.8, 0, 0, 1], 3, 1);
		}
	}

	public function hideInfo():Void {
		infoText = "";
	}

	public function gotoGraph(graph:Graph):Void {
		this.graph.gotoGraph(graph);
		breadcrumb.updatePath();
	}

	public function loadAsRoot(data:GraphData, vibration:Bool):Void {
		var root = graph.raw.getRoot();
		root.destroyEverything();
		var newRoot = Graph.deserialize(data, root.listener, vibration);
		gotoGraph(newRoot);
	}

	public function copy(data:GraphData):Void {
		clipboard.copy(data);
	}

	public function undo():Void {
		graph.undo();
	}

	public function redo():Void {
		graph.redo();
	}

	public function canUndo():Bool {
		return graph.canUndo();
	}

	public function canRedo():Bool {
		return graph.canRedo();
	}

	public function paste(data:GraphData = null, infoVerb:String = "paste"):Bool {
		if (data == null)
			data = clipboard.data;
		if (data == null)
			return false;
		clickController.click.gotoPasteMode(data, infoVerb);
		return true;
	}

	override function update() {
		waveData.resize(0);
		graph.raw.listener.onWaveDataRequest(waveData);

		processKeyInputs();
		graph.raw.stepPhysics();
	}

	function processKeyInputs():Void {
		if (graph.op.getTopMenu() != null)
			return;
		var keyboard = graph.op.getKeyboard();
		var ctrl = keyboard.isControlDown();
		var alt = keyboard.isAltDown();
		var shift = keyboard.isShiftDown();
		if (ctrl && !shift && !alt && keyboard.isKeyDown("z")) {
			toolbar.undo();
		}
		if (ctrl && !shift && !alt && keyboard.isKeyDown("y")) {
			toolbar.redo();
		}
		if (ctrl && !shift && !alt && keyboard.isKeyDown("x")) {
			toolbar.cut(false);
		}
		if (ctrl && !shift && !alt && keyboard.isKeyDown("c")) {
			toolbar.copy(false);
		}
		if (ctrl && !shift && !alt && keyboard.isKeyDown("v")) {
			toolbar.paste(false);
		}
		if (!ctrl && !shift && !alt && keyboard.isKeyDown(Enter)) {
			if (graph.selection.count() == 1)
				graph.interact(graph.selection.toArray()[0]);
		}
		if (ctrl && !shift && !alt && keyboard.isKeyDown("a")) {
			toolbar.selectAll(false);
		}
		if (!ctrl && !shift && !alt && (keyboard.isKeyDown(Backspace) || keyboard.isKeyDown(Delete))) {
			toolbar.remove(false);
		}
		if (!ctrl && !shift && !alt && keyboard.isKeyDown(Escape)) {
			graph.selection.clear();
		}
	}

	override function draw(g:Graphics) {
		g.fill(1, 1, 1);
		g.rect(0, 0, width, height, Fill);
		g.saved(() -> {
			graph.view.applyTransform(g);
			renderer.draw(g, graph);
		});
	}
}
