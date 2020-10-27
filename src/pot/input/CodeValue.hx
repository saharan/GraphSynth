package pot.input;

enum abstract CodeValue(String) {
	var Escape = "Escape";
	var Digit0 = "Digit0";
	var Digit1 = "Digit1";
	var Digit2 = "Digit2";
	var Digit3 = "Digit3";
	var Digit4 = "Digit4";
	var Digit5 = "Digit5";
	var Digit6 = "Digit6";
	var Digit7 = "Digit7";
	var Digit8 = "Digit8";
	var Digit9 = "Digit9";
	var Minus = "Minus";
	var Equal = "Equal";
	var Backspace = "Backspace";
	var Tab = "Tab";
	var KeyQ = "KeyQ";
	var KeyW = "KeyW";
	var KeyE = "KeyE";
	var KeyR = "KeyR";
	var KeyT = "KeyT";
	var KeyY = "KeyY";
	var KeyU = "KeyU";
	var KeyI = "KeyI";
	var KeyO = "KeyO";
	var KeyP = "KeyP";
	var BracketLeft = "BracketLeft";
	var BracketRight = "BracketRight";
	var Enter = "Enter";
	var ControlLeft = "ControlLeft";
	var KeyA = "KeyA";
	var KeyS = "KeyS";
	var KeyD = "KeyD";
	var KeyF = "KeyF";
	var KeyG = "KeyG";
	var KeyH = "KeyH";
	var KeyJ = "KeyJ";
	var KeyK = "KeyK";
	var KeyL = "KeyL";
	var Semicolon = "Semicolon";
	var Quote = "Quote";
	var Backquote = "Backquote";
	var ShiftLeft = "ShiftLeft";
	var Backslash = "Backslash";
	var KeyZ = "KeyZ";
	var KeyX = "KeyX";
	var KeyC = "KeyC";
	var KeyV = "KeyV";
	var KeyB = "KeyB";
	var KeyN = "KeyN";
	var KeyM = "KeyM";
	var Comma = "Comma";
	var Period = "Period";
	var Slash = "Slash";
	var ShiftRight = "ShiftRight";
	var NumpadMultiply = "NumpadMultiply";
	var AltLeft = "AltLeft";
	var Space = "Space";
	var CapsLock = "CapsLock";
	var F1 = "F1";
	var F2 = "F2";
	var F3 = "F3";
	var F4 = "F4";
	var F5 = "F5";
	var F6 = "F6";
	var F7 = "F7";
	var F8 = "F8";
	var F9 = "F9";
	var F10 = "F10";
	var Numpad7 = "Numpad7";
	var Numpad8 = "Numpad8";
	var Numpad9 = "Numpad9";
	var NumpadSubtract = "NumpadSubtract";
	var Numpad4 = "Numpad4";
	var Numpad5 = "Numpad5";
	var Numpad6 = "Numpad6";
	var NumpadAdd = "NumpadAdd";
	var Numpad1 = "Numpad1";
	var Numpad2 = "Numpad2";
	var Numpad3 = "Numpad3";
	var Numpad0 = "Numpad0";
	var NumpadDecimal = "NumpadDecimal";
	var IntlBackslash = "IntlBackslash";
	var F11 = "F11";
	var F12 = "F12";
	var IntlYen = "IntlYen";
	var NumpadEnter = "NumpadEnter";
	var ControlRight = "ControlRight";
	var NumpadDivide = "NumpadDivide";
	var PrintScreen = "PrintScreen";
	var AltRight = "AltRight";
	var NumLock = "NumLock";
	var Home = "Home";
	var ArrowUp = "ArrowUp";
	var PageUp = "PageUp";
	var ArrowLeft = "ArrowLeft";
	var ArrowRight = "ArrowRight";
	var End = "End";
	var ArrowDown = "ArrowDown";
	var PageDown = "PageDown";
	var Insert = "Insert";
	var Delete = "Delete";
	var ContextMenu = "ContextMenu";

	public static final DIGITS:Array<CodeValue> = [Digit0, Digit1, Digit2, Digit3, Digit4, Digit5, Digit6, Digit7, Digit8, Digit9];
	public static final FUNCTIONS:Array<CodeValue> = [F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12];
	public static final ALL:Array<CodeValue> = [
		Escape,
		Digit0,
		Digit1,
		Digit2,
		Digit3,
		Digit4,
		Digit5,
		Digit6,
		Digit7,
		Digit8,
		Digit9,
		Minus,
		Equal,
		Backspace,
		Tab,
		KeyQ,
		KeyW,
		KeyE,
		KeyR,
		KeyT,
		KeyY,
		KeyU,
		KeyI,
		KeyO,
		KeyP,
		BracketLeft,
		BracketRight,
		Enter,
		ControlLeft,
		KeyA,
		KeyS,
		KeyD,
		KeyF,
		KeyG,
		KeyH,
		KeyJ,
		KeyK,
		KeyL,
		Semicolon,
		Quote,
		Backquote,
		ShiftLeft,
		Backslash,
		KeyZ,
		KeyX,
		KeyC,
		KeyV,
		KeyB,
		KeyN,
		KeyM,
		Comma,
		Period,
		Slash,
		ShiftRight,
		NumpadMultiply,
		AltLeft,
		Space,
		CapsLock,
		F1,
		F2,
		F3,
		F4,
		F5,
		F6,
		F7,
		F8,
		F9,
		F10,
		Numpad7,
		Numpad8,
		Numpad9,
		NumpadSubtract,
		Numpad4,
		Numpad5,
		Numpad6,
		NumpadAdd,
		Numpad1,
		Numpad2,
		Numpad3,
		Numpad0,
		NumpadDecimal,
		IntlBackslash,
		F11,
		F12,
		IntlYen,
		NumpadEnter,
		ControlRight,
		NumpadDivide,
		PrintScreen,
		AltRight,
		NumLock,
		Home,
		ArrowUp,
		PageUp,
		ArrowLeft,
		ArrowRight,
		End,
		ArrowDown,
		PageDown,
		Insert,
		Delete,
		ContextMenu
	];
	public static function fromString(code:String):Null<CodeValue> {
		if (ALL.indexOf(cast code) == -1)
			return null;
		return cast code;
	}
}
