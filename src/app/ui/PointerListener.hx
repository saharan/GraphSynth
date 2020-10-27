package app.ui;

interface PointerListener {
	function onPointerEnter(p:Pointer):Void;
	function onPointerExit(p:Pointer):Void;
	function onPointerDown(p:Pointer, index:Int):Void;
	function onPointerUp(p:Pointer, index:Int):Void;
	function onPointerMove(p:Pointer):Void;
	function onWheel(p:Pointer, amount:Float):Void;
}
