package render;

class ViewData {
	public var centerX:Float;
	public var centerY:Float;
	public var scale:Float;

	public function new() {
		centerX = 0;
		centerY = 0;
		scale = 1;
	}

	public function copy():ViewData {
		var res = new ViewData();
		res.centerX = centerX;
		res.centerY = centerY;
		res.scale = scale;
		return res;
	}
}
