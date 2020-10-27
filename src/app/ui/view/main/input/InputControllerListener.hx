package app.ui.view.main.input;

interface InputControllerListener {
	function onClickBegin(x:Float, y:Float):Void;
	function onClickMove(x:Float, y:Float):Void;
	function onClickCancel():Void;
	function onClickEnd():Void;
	function onPinchBegin(x1:Float, y1:Float, x2:Float, y2:Float):Void;
	function onPinchMove(x1:Float, y1:Float, x2:Float, y2:Float):Void;
	function onPinchEnd():Void;
	function onPanBegin(x:Float, y:Float):Void;
	function onPanMove(x:Float, y:Float):Void;
	function onPanEnd():Void;
	function onWheel(x:Float, y:Float, amount:Float):Void;
}
