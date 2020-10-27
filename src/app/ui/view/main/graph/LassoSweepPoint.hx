package app.ui.view.main.graph;

enum LassoSweepPoint {
	LineBegin(index:Int, vertex:Int);
	LineEnd(index:Int, vertex:Int);
	NodeCenter(index:Int, x:Float, y:Float);
}
