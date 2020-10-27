package app.ui.core;

@:using(app.ui.core.Length.LengthTools)
enum Length {
	Px(p:Float);
	Percent(p:Float);
	Add(a:Length, b:Length);
	Sub(a:Length, b:Length);
	Zero;
}

class LengthTools {
	public static function calc(l:Length, base:Float):Float {
		return switch l {
			case Px(p):
				p;
			case Percent(p):
				base != null ? p / 100 * base : 0;
			case Add(a, b):
				calc(a, base) + calc(b, base);
			case Sub(a, b):
				calc(a, base) - calc(b, base);
			case Zero:
				0;
		}
	}
}
