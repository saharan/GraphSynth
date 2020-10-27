package app;

import app.ui.view.main.graph.ClickSettings;
import pot.input.Keyboard;
import haxe.Serializer;
import app.graphics.Graphics;
import app.ui.Sprite;
import app.ui.Stage;
import app.ui.core.Element;
import app.ui.core.layout.FlexLayout;
import app.ui.core.layout.OverlayLayout;
import app.ui.view.main.KeyboardSprite;
import app.ui.view.main.MainSprite;
import app.ui.view.main.PointerDetector;
import app.ui.view.menu.EventStopper;
import app.ui.view.menu.Menu;
import common.Pair;
import graph.Graph;
import graph.serial.GraphData;
import graph.serial.NodeFilter;
import haxe.Json;
import js.Browser;
import js.html.MouseEvent;
import pot.core.App;
import pot.input.Input;

using common.FloatTools;

class Main extends App implements MainOperator {
	public static var inputForDebug:Input;

	var stage:Stage;
	var octaveBase:Int = 4;

	public function new() {
		super(cast Browser.document.getElementById("canvas"), true);
	}

	override function setup() {
		pot.resize(400, 500, 1);

		var isMobile = ~/iPhone|Android.*Mobile/.match(Browser.window.navigator.userAgent);
		if (isMobile)
			ClickSettings.setForMobiles();
		else
			ClickSettings.setForDesktops();

		function resize():Void {
			var newPixelRatio = Browser.window.devicePixelRatio;
			var w = Math.ceil(canvas.parentElement.offsetWidth * newPixelRatio);
			var h = Math.ceil(canvas.parentElement.offsetHeight * newPixelRatio);
			if (pot.pixelRatio != newPixelRatio || pot.width != w || pot.height != h) {
				pot.resize(w, h, newPixelRatio);
				rescaleRenderer();
			}
		}
		canvas.style.width = null;
		canvas.style.height = null;
		Browser.window.addEventListener("resize", resize);
		resize();

		pot.frameRate(60);

		inputForDebug = input;

		init();

		pot.start();
	}

	function rescaleRenderer():Void {
		if (stage == null)
			return;
		var minW = 300;
		var minH = 375;

		var screenW = canvas.width;
		var screenH = canvas.height;

		inline function min(a:Float, b:Float, c:Float):Float {
			var ab = a < b ? a : b;
			return ab < c ? ab : c;
		}

		var scaleW = screenW / minW;
		var scaleH = screenH / minH;
		var maxScale = pot.pixelRatio * 2;
		var scale = min(scaleW, scaleH, maxScale);

		stage.resize(screenW / scale, screenH / scale);
		stage.scale = scale;

		trace('scaling: window = ($screenW, $screenH), target = ($minW, $minH), scale = $scale');
	}

	var keyboardSprite:KeyboardSprite;
	var mainSprite:MainSprite;
	var menuWrapper:Sprite;
	var menuesToOpen:Array<Menu> = [];
	var menuesOpening:Array<Menu> = [];

	var compiler:WebAudioCompiler;

	function init():Void {
		stage = new Stage(input, new Graphics(canvas));

		var wrapper = new Sprite(new Element());
		wrapper.style.size.set(Percent(100), Percent(100));
		wrapper.layout = new FlexLayout(Y);

		compiler = new WebAudioCompiler();

		var g = new Graph(compiler);

		mainSprite = new MainSprite(g, this);
		wrapper.addChild(mainSprite);
		keyboardSprite = new KeyboardSprite(() -> octaveBase, this);
		wrapper.addChild(keyboardSprite);

		var root = stage.root;
		root.element.layout = new OverlayLayout();
		root.addChild(wrapper);

		// menu = new Menu();
		// root.addChild(menu);
		// root.addChild(new EditNumberDialogue(100, _ -> {}, () -> {}));
		menuWrapper = new Sprite();
		menuWrapper.layout = new OverlayLayout();
		menuWrapper.style.size.set(Percent(100), Percent(100));
		root.addChild(menuWrapper);

		root.addChild(new PointerDetector());

		rescaleRenderer();

		showModalDialogue("Click to Play", compiler.start);
	}

	function showModalDialogue(text:String, onClick:Void->Void):Void {
		var cover = Browser.document.getElementById("cover");
		var coverText = Browser.document.getElementById("cover-text");
		coverText.innerText = text;
		var listener:MouseEvent->Void = null;
		listener = e -> {
			onClick();
			cover.removeEventListener("click", listener);
			cover.classList.add("hidden");
		}
		cover.addEventListener("click", listener);
		cover.classList.remove("hidden");
	}

	function importData():Pair<LoadResult, Pair<GraphData, Graph>> {
		var text = Browser.window.prompt("Input text data");
		if (text == null || text == "")
			return Pair.of(LoadResult.Cancelled, null);
		try {
			var data = Json.parse(text);
			var g = Graph.deserialize(data);
			return Pair.of(LoadResult.Succeeded, Pair.of(data, g));
		} catch (e) {
			Browser.alert("invalid data");
			return Pair.of(LoadResult.Failed, null);
		}
	}

	// ------------------------------------------- <op>

	public function reset():Void {
		mainSprite.resetGraph();
	}

	public function changeOctave(diff:Int):Void {
		octaveBase += diff;
		if (octaveBase < 0)
			octaveBase = 0;
		if (octaveBase > 9)
			octaveBase = 9;
	}

	public function selectNodeCreation(n:NodeInfo):Void {
		mainSprite.selectNodeCreation(n);
	}

	public function showInfo(text:String, type:InfoType):Void {
		mainSprite.showInfo(text, type);
	}

	public function hideInfo():Void {
		mainSprite.hideInfo();
	}

	public function closeToolbar():Void {
		mainSprite.closeToolbar();
	}

	public function gotoGraph(graph:Graph):Void {
		mainSprite.gotoGraph(graph);
	}

	public function loadAsRoot(data:GraphData, vibration:Bool):Void {
		mainSprite.loadAsRoot(data, vibration);
	}

	public function openMenu(menu:Menu):Void {
		menuesToOpen.push(menu);
	}

	public function copy(data:GraphData):Void {
		mainSprite.copy(data);
	}

	public function paste():Bool {
		return mainSprite.paste();
	}

	public function importGraph():LoadResult {
		var pair = importData();
		switch pair.a {
			case Succeeded:
				var data = pair.b.a;
				var g = pair.b.b;
				if (!g.containsOutput()) {
					// add an output node automatically
					var maxX = 0.0;
					for (node in g.nodes) {
						maxX = maxX.max(node.getX());
					}
					NodeList.OUTPUT.create(g, maxX + 80, 0, false);
					data = g.serialize(NodeFilter.ALL, false);
				}
				mainSprite.loadAsRoot(data, true);
				return Succeeded;
			case Failed:
				return Failed;
			case Cancelled:
				return Cancelled;
		}
	}

	public function exportData(data:GraphData):Void {
		trace(Serializer.run(data));

		var text = Json.stringify(data);

		showModalDialogue("Copying...", () -> {
			var doc = Browser.document;
			var input = doc.createPreElement();
			doc.body.appendChild(input);
			input.innerText = text;

			var sel = doc.getSelection();
			sel.selectAllChildren(input);
			doc.execCommand("copy");
			sel.removeAllRanges();
			doc.body.removeChild(input);

			showInfo("Copied!", Info);
		});
	}

	public function importModule():LoadResult {
		var pair = importData();
		switch pair.a {
			case Succeeded:
				var data = pair.b.a;
				var g = pair.b.b;
				if (g.containsOutput()) {
					// delete the output node automatically
					data = g.serialize(new NodeFilter(node -> !node.setting.role.match(Destination)), false);
				}
				mainSprite.paste(data, "import");
				return Succeeded;
			case Failed:
				return Failed;
			case Cancelled:
				return Cancelled;
		}
	}

	public function getTopMenu():Null<Menu> {
		if (menuesOpening.length == 0)
			return null;
		return menuesOpening[menuesOpening.length - 1];
	}

	public function getKeyboard():Keyboard {
		return input.keyboard;
	}

	public function attack():Void {
		compiler.attack();
	}

	public function release():Void {
		compiler.release();
	}

	public function setFrequency(f:Float, time:Float):Void {
		compiler.setFrequency(f, time);
	}

	// ------------------------------------------- </op>

	override function loop() {
		for (menu in menuesToOpen) {
			menuWrapper.addChild(menu);
			menuesOpening.push(menu);
		}
		if (menuesToOpen.length > 0) {
			menuWrapper.addChild(new EventStopper(Menu.ANIMATION_DURATION));
		}
		menuesOpening = menuesOpening.filter(menu -> menu.parent != null);
		menuesToOpen.resize(0);
		stage.update();
		canvas.style.cursor = stage.cursor;
		stage.draw();
	}

	static function main() {
		new Main();
	}
}
