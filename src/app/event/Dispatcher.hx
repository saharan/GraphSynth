package app.event;

class Dispatcher<T> {
	final listeners:Array<T> = [];

	public function addListener(listener:T):Bool {
		if (listeners.indexOf(listener) != -1)
			return false;
		listeners.push(listener);
		return true;
	}

	public function removeListener(listener:T):Bool {
		return listeners.remove(listener);
	}

	function dispatch(f:T->Void):Void {
		for (l in listeners) {
			f(l);
		}
	}
}
