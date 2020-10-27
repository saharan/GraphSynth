package app.ui.view.menu.nodeedit;

@:using(app.ui.view.menu.nodeedit.NumberRange.NumberRangeTools)
enum abstract NumberRange(String) {
	var Real = "real";
	var Hz = "hz";
	var Sec = "sec";
	var Level = "level";
}

class NumberRangeTools {
	public static function min(range:NumberRange):Float {
		return switch range {
			case Real | Hz:
				0;
			case Sec:
				0;
			case Level:
				0;
		}
	}

	public static function max(range:NumberRange):Float {
		return switch range {
			case Real | Hz:
				10000;
			case Sec:
				10;
			case Level:
				1;
		}
	}

	public static function signed(range:NumberRange):Bool {
		return switch range {
			case Real:
				true;
			case Hz | Sec | Level:
				false;
		}
	}
}
