package pot.util;
import js.html.Image;

/**
 * ...
 */
class ImageLoader {
	public static function loadImages(sources:Array<String>, onLoad:Array<Image> -> Void, onError:Void -> Void = null):Void {
		var cnt:Int = sources.length;
		var error:Bool = false;
		var images:Array<Image> = sources.map((src) -> {
			var image:Image = new Image();
			image.src = src;
			return image;
		});
		for (image in images) {
			image.onload = () -> {
				if (--cnt == 0) {
					onLoad(images);
				}
			};
			image.onerror = () -> {
				if (!error) {
					onError();
					error = true;
				}
			};
		}
	}
}
