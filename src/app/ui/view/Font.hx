package app.ui.view;

class Font {
	public static inline final FONT_NAME:String = "Courier New";
	public static inline final FONT_BASE_SIZE:Float = 10;
	public static inline final BOLD:Bool = true;

	public static function measure(text:String):Float {
		return 3 + 6 * text.length;
	}
}
