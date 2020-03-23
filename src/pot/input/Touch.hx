package pot.input;

/**
 * ...
 */
@:allow(pot.input.Input)
@:allow(pot.input.Touches)
@:allow(pot.input.TouchesData)
class Touch {
	public var px(default, null):Float;
	public var py(default, null):Float;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var dx(default, null):Float;
	public var dy(default, null):Float;
	public var id(default, null):Int;
	public var touching(default, null):Bool;
	public var ptouching(default, null):Bool;
	public var dtouching(default, null):Int;

	var rawId:Int;
	var nx:Float;
	var ny:Float;
	var ntouching:Bool;
	var ntouching2:Bool;

	public function new() {
		px = 0;
		py = 0;
		x = 0;
		y = 0;
		nx = 0;
		ny = 0;
		dx = 0;
		dy = 0;
		ptouching = false;
		touching = false;
		ntouching = false;
		ntouching2 = false;
		dtouching = 0;
		rawId = 0;
	}

	@:extern
	inline function begin(x:Float, y:Float):Void {
		nx = x;
		ny = y;
		ntouching = true;
		ntouching2 = true;
	}

	@:extern
	inline function move(x:Float, y:Float):Void {
		nx = x;
		ny = y;
	}

	@:extern
	inline function end(x:Float, y:Float):Void {
		nx = x;
		ny = y;
		ntouching = false;
	}

	function update():Void {
		px = x;
		py = y;
		x = nx;
		y = ny;
		dx = x - px;
		dy = y - py;
		ptouching = touching;
		touching = ntouching || ntouching2;
		ntouching2 = false;
		dtouching = (touching ? 1 : 0) - (ptouching ? 1 : 0);
	}

}
