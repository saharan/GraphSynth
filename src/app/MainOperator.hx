package app;

import pot.input.Keyboard;
import graph.serial.GraphData;
import graph.Graph;
import app.ui.view.menu.Menu;

interface MainOperator {
	function reset():Void;
	function openMenu(menu:Menu):Void;
	function changeOctave(diff:Int):Void;
	function selectNodeCreation(n:NodeInfo):Void;
	function showInfo(text:String, infoType:InfoType):Void;
	function hideInfo():Void;
	function closeToolbar():Void;
	function gotoGraph(graph:Graph):Void; // this updates the breadcrumb
	function loadAsRoot(data:GraphData, vibration:Bool):Void;
	function copy(data:GraphData):Void;
	function paste():Bool;

	function importGraph():LoadResult;
	function importModule():LoadResult;
	function exportData(data:GraphData):Void;

	function getTopMenu():Null<Menu>;
	function getKeyboard():Keyboard;

	// control envelopes
	function attack():Void;
	function release():Void;
	function setFrequency(f:Float, time:Float):Void;
}
