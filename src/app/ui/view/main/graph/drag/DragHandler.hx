package app.ui.view.main.graph.drag;

interface DragHandler {
	function move(x:Float, y:Float):Void;
	function done():Void;
	function cancel():Void;
}
