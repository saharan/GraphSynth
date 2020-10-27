package app.ui.view.main.input;

import app.event.Dispatcher;

class InputController implements PointerListener extends Dispatcher<InputControllerListener> {
	var state:InputControllerState;
	var rightClickState:InputControllerState;

	public function new() {
		state = Idle;
		rightClickState = Idle;
	}

	public function onPointerEnter(p:Pointer):Void {
	}

	public function onPointerExit(p:Pointer):Void {
	}

	public function onPointerDown(pointer:Pointer, index:Int):Void {
		switch index {
			case 0:
				switch state {
					case Idle:
						dispatch(l -> l.onClickBegin(pointer.x, pointer.y));
						state = Clicking(pointer);
					case Clicking(p):
						dispatch(l -> l.onClickCancel());
						dispatch(l -> l.onPinchBegin(p.x, p.y, pointer.x, pointer.y));
						state = Pinching(p, pointer);
					case Pinching(_, _): // do nothing
					case WaitForPinch(p):
						dispatch(l -> l.onPinchBegin(p.x, p.y, pointer.x, pointer.y));
						state = Pinching(p, pointer);
				}
			case 1:
				switch rightClickState {
					case Idle:
						dispatch(l -> l.onPanBegin(pointer.x, pointer.y));
						rightClickState = Clicking(pointer);
					case Clicking(_): // do nothing
					case _:
						throw "invalid right click state";
				}
		}
	}

	public function onPointerUp(pointer:Pointer, index:Int):Void {
		switch index {
			case 0:
				switch state {
					case Idle: // do nothing
					case Clicking(p):
						if (p == pointer) {
							dispatch(l -> l.onClickEnd());
							state = Idle;
						}
					case Pinching(p1, p2):
						var left = pointer == p1 ? p2 : pointer == p2 ? p1 : null;
						if (left != null) {
							dispatch(l -> l.onPinchEnd());
							state = WaitForPinch(left);
						}
					case WaitForPinch(p):
						if (p == pointer) state = Idle;
				}
			case 1:
				switch rightClickState {
					case Idle: // do nothing
					case Clicking(p):
						if (p == pointer) {
							dispatch(l -> l.onPanEnd());
							rightClickState = Idle;
						}
					case _:
						throw "invalid right click state";
				}
		}
	}

	public function onPointerMove(pointer:Pointer):Void {
		switch rightClickState {
			case Idle: // do nothing
			case Clicking(p):
				if (p == pointer)
					dispatch(l -> l.onPanMove(p.x, p.y));
			case _:
				throw "invalid right click state";
		}
		switch state {
			case Idle: // do nothing
			case Clicking(p):
				if (p == pointer)
					dispatch(l -> l.onClickMove(p.x, p.y));
			case Pinching(p1, p2):
				if (p1 == pointer || p2 == pointer)
					dispatch(l -> l.onPinchMove(p1.x, p1.y, p2.x, p2.y));
			case WaitForPinch(_): // do nothing
		}
	}

	public function onWheel(p:Pointer, amount:Float):Void {
		dispatch(l -> l.onWheel(p.x, p.y, amount));
	}
}
