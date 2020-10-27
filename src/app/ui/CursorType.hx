package app.ui;

enum abstract CursorType(String) to String {
	var Auto = "auto";
	var Default = "default";
	var Pointer = "pointer";
	var Crosshair = "crosshair";
	var Move = "move";
	var Text = "text";
	var Wait = "wait";
	var Help = "help";
	var resizeN = "n-resize";
	var resizeS = "s-resize";
	var resizeW = "w-resize";
	var resizeE = "e-resize";
	var resizeNE = "ne-resize";
	var resizeNW = "nw-resize";
	var resizeSE = "se-resize";
	var resizeSW = "sw-resize";
	var Progress = "progress";
}
