package app.ui;

class Pointer {
	public var id(default, null):Int;
	public var isPrimary:Bool;
	public var x:Float;
	public var y:Float;
	public var downBits:Int;

	public function new(id:Int, isPrimary:Bool) {
		this.id = id;
		this.isPrimary = isPrimary;
		x = 0;
		y = 0;
		downBits = 0;
	}

	public inline function isDown(index:Int):Bool {
		return downBits >> index & 1 == 1;
	}

	@:allow(app.ui.PointerManager)
	inline function down(index:Int):Void {
		downBits |= 1 << index;
	}

	@:allow(app.ui.PointerManager)
	inline function up(index:Int):Void {
		downBits &= ~(1 << index);
	}
}
