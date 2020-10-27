package app.ui.core;

@:using(app.ui.core.LengthOrAuto.LengthOrAutoTools)
enum LengthOrAuto {
	Px(p:Float);
	Percent(p:Float);
	Add(a:Length, b:Length);
	Sub(a:Length, b:Length);
	Zero;
	Auto;
}

class LengthOrAutoTools {
	public static function toLength(l:LengthOrAuto, whenAuto:Length):Length {
		return switch l {
			case Auto:
				whenAuto;
			case Px(p):
				Px(p);
			case Percent(p):
				Percent(p);
			case Add(a, b):
				Add(a, b);
			case Sub(a, b):
				Sub(a, b);
			case Zero:
				Zero;
		}
	}
}
