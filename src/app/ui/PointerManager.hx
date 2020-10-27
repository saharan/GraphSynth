package app.ui;

import app.event.Dispatcher;

class PointerManager extends Dispatcher<PointerListener> {
	public final pointers:Array<Pointer> = [];

	final originX:Gen<Float>;
	final originY:Gen<Float>;

	public var primaryPointer(get, never):Pointer;

	extern inline function get_primaryPointer():Pointer {
		var res = null;
		for (p in pointers) {
			if (p.isPrimary) {
				res = p;
				break;
			}
		}
		return res;
	}

	public function new(originX:Gen<Float>, originY:Gen<Float>) {
		this.originX = originX;
		this.originY = originY;
	}

	public function onEnter(id:Int, downBits:Int):Void {
		var p = new Pointer(id, pointers.length == 0);
		p.downBits = downBits;
		pointers.push(p);
		dispatch(l -> l.onPointerEnter(p));
	}

	public function onExit(id:Int):Void {
		var p = get(id);
		dispatch(l -> l.onPointerExit(p));
		pointers.remove(p);
	}

	public function onDown(id:Int, index:Int):Void {
		var p = get(id);
		p.down(index);
		dispatch(l -> l.onPointerDown(p, index));
	}

	public function onUp(id:Int, index:Int):Void {
		var p = get(id);
		p.up(index);
		dispatch(l -> l.onPointerUp(p, index));
	}

	public function onMove(id:Int, x:Float, y:Float):Void {
		var p = get(id);
		p.x = x - originX();
		p.y = y - originY();
		dispatch(l -> l.onPointerMove(p));
	}

	public function onWheel(id:Int, amount:Float):Void {
		var p = get(id);
		dispatch(l -> l.onWheel(p, amount));
	}

	inline function get(id:Int):Pointer {
		var res = null;
		for (p in pointers) {
			if (p.id == id) {
				res = p;
				break;
			}
		}
		return res;
	}
}
