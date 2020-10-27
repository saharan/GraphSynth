package app.ui.view.main.input;

import app.ui.Pointer;

enum InputControllerState {
	Idle;
	Clicking(p:Pointer);
	Pinching(p1:Pointer, p2:Pointer);
	WaitForPinch(p:Pointer);
}
