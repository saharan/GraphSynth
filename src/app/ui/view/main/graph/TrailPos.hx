package app.ui.view.main.graph;

abstract TrailPos(Array<Float>) from Array<Float> {
	public var x(get, never):Float;
	public var y(get, never):Float;

	function get_x():Float {
		return this[0];
	}

	function get_y():Float {
		return this[1];
	}

	public function dist(pos:TrailPos):Float {
		var dx = x - pos.x;
		var dy = y - pos.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
}
