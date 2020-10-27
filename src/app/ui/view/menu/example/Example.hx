package app.ui.view.menu.example;

import graph.serial.GraphData;

class Example {
	public final name:String;
	public final data:GraphData;

	public function new(name:String, data:GraphData) {
		this.name = name;
		this.data = data;
	}
}
