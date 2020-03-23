package synth;

class NumberData {
	var valueInt:Int;

	public var value(get, set):Float;

	public function new(x:Float) {
		value = x;
	}

	function get_value():Float {
		return valueInt / 10000;
	}

	function set_value(v:Float):Float {
		v = v > 10000 ? 10000 : v < -10000 ? -10000 : v;
		var vi = Math.round(v * 10000);
		if (vi == 0 && v != 0)
			vi = v > 0 ? 1 : -1;
		valueInt = vi;
		return value;
	}
}
