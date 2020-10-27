package app.ui.view.main.graph;

import app.ui.view.main.input.InputControllerListener;

class ClickController implements InputControllerListener {
	final graph:GraphWrapper;

	public final click:Click;

	var clicking:Bool;

	public function new(graph:GraphWrapper) {
		this.graph = graph;
		click = new Click(graph);
		clicking = false;
	}

	public function onClickBegin(x:Float, y:Float):Void {
		if (clicking)
			throw "double begin call";
		clicking = true;
		click.begin(graph.view.worldX(x), graph.view.worldY(y));
	}

	public function onClickMove(x:Float, y:Float):Void {
		if (clicking)
			click.move(graph.view.worldX(x), graph.view.worldY(y));
	}

	public function onClickCancel():Void {
		if (!clicking)
			throw "cannot cancel";
		clicking = false;
		click.cancel();
	}

	public function onClickEnd():Void {
		if (!clicking)
			throw "cannot end";
		clicking = false;
		click.end();
	}

	public function onPinchBegin(x1:Float, y1:Float, x2:Float, y2:Float):Void {
	}

	public function onPinchMove(x1:Float, y1:Float, x2:Float, y2:Float):Void {
	}

	public function onPinchEnd():Void {
	}

	public function onPanBegin(x:Float, y:Float):Void {
	}

	public function onPanMove(x:Float, y:Float):Void {
	}

	public function onPanEnd():Void {
	}

	public function onWheel(x:Float, y:Float, amount:Float):Void {
	}
}
