package app.ui.view.main.graph.history;

import graph.serial.GraphData;

class HistoryPoint {
	public final data:GraphData;
	public final atGraphId:Int;

	public function new(data:GraphData, atGraphId:Int) {
		this.data = data;
		this.atGraphId = atGraphId;
	}
}
