package app;

import js.html.CanvasElement;
import graph.Graph;
import render.Renderer;

class Control {
	public var context(default, null):Context;

	public var renderer(get, never):Renderer;
	public var graph(get, never):Graph;

	public var nextControl:Control;
	public var lastInputSource:InputSource;

	public function new(context:Context) {
		this.context = context;
	}

	public function onDragBegin(x:Float, y:Float, tapCount:Int):Void {}

	public function onPressing(x:Float, y:Float):Void {}

	public function onLongPress(x:Float, y:Float, tapCount:Int):Void {}

	public function onReleased(x:Float, y:Float, tapCount:Int):Void {}

	public function step(x:Float, y:Float, touching:Bool):Void {}

	function get_renderer():Renderer {
		return context.renderer;
	}

	function get_graph():Graph {
		return context.graph;
	}
}
