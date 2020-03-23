package app;

import render.Renderer;
import js.html.CanvasElement;
import graph.Graph;

class Context {
	public var canvas:CanvasElement;
	public var graph:Graph;
	public var renderer:Renderer;
	public var clipboard:Clipboard;

	public function new(canvas:CanvasElement, graph:Graph, renderer:Renderer, clipboard:Clipboard) {
		this.canvas = canvas;
		this.graph = graph;
		this.renderer = renderer;
		this.clipboard = clipboard;
	}

	public function changeGraph(to:Graph):Context {
		return new Context(canvas, to, renderer, clipboard);
	}
}
