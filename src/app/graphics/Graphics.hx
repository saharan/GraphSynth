package app.graphics;

import js.html.CanvasWindingRule;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Graphics {
	static inline final PI:Float = 3.141592653589793;
	static inline final TWO_PI:Float = PI * 2;
	static inline final HALF_PI:Float = PI * 0.5;

	final canvas:CanvasElement;
	final c2d:CanvasRenderingContext2D;

	public var context(get, never):CanvasRenderingContext2D;

	extern inline function get_context():CanvasRenderingContext2D {
		return c2d;
	}

	public function new(canvas:CanvasElement) {
		this.canvas = canvas;
		c2d = canvas.getContext2d();
	}

	public function font(name:String, size:Float, bold:Bool):Void {
		c2d.font = (bold ? "bold " : "") + '${size}px "$name"';
	}

	extern public inline function fill(r:Float, g:Float, b:Float, a:Float = 1.0):Void {
		c2d.fillStyle = 'rgba(${Std.int(r * 255.0)},${Std.int(g * 255.0)},${Std.int(b * 255.0)},$a)';
	}

	extern public inline function stroke(r:Float, g:Float, b:Float, a:Float = 1.0):Void {
		c2d.strokeStyle = 'rgba(${Std.int(r * 255.0)},${Std.int(g * 255.0)},${Std.int(b * 255.0)},$a)';
	}

	extern public inline function textBaseline(baseline:TextBaseline):Void {
		c2d.textBaseline = baseline;
	}

	extern public inline function textAlign(align:TextAlign):Void {
		c2d.textAlign = align;
	}

	extern public inline function lineCap(cap:LineCap):Void {
		c2d.lineCap = cap;
	}

	extern public inline function lineJoin(join:LineJoin):Void {
		c2d.lineJoin = join;
	}

	extern public inline function lineWidth(width:Float):Void {
		c2d.lineWidth = width;
	}

	extern public inline function beginPath():Void {
		c2d.beginPath();
	}

	extern public inline function closePath():Void {
		c2d.closePath();
	}

	extern public inline function moveTo(x:Float, y:Float):Void {
		c2d.moveTo(x, y);
	}

	extern public inline function lineTo(x:Float, y:Float):Void {
		c2d.lineTo(x, y);
	}

	extern public inline function arcTo(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float):Void {
		c2d.arcTo(x1, y1, x2, y2, radius);
	}

	extern public inline function line(x1:Float, y1:Float, x2:Float, y2:Float):Void {
		beginPath();
		moveTo(x1, y1);
		lineTo(x2, y2);
		strokePath();
	}

	extern public inline function fillPath(rule:CanvasWindingRule = EVENODD):Void {
		c2d.fill(rule);
	}

	extern public inline function strokePath():Void {
		c2d.stroke();
	}

	extern public inline function saved(draw:Void->Void):Void {
		c2d.save();
		draw();
		c2d.restore();
	}

	extern public inline function circle(x:Float, y:Float, r:Float, mode:DrawMode):Void {
		c2d.beginPath();
		c2d.arc(x, y, r, 0, TWO_PI);
		switch mode {
			case Stroke:
				c2d.stroke();
			case Fill:
				c2d.fill();
			case Both:
				c2d.fill();
				c2d.stroke();
		}
	}

	extern public inline function rect(x:Float, y:Float, w:Float, h:Float, mode:DrawMode):Void {
		switch mode {
			case Stroke:
				c2d.strokeRect(x, y, w, h);
			case Fill:
				c2d.fillRect(x, y, w, h);
			case Both:
				c2d.fillRect(x, y, w, h);
				c2d.strokeRect(x, y, w, h);
		}
	}

	extern public inline function roundRect(x:Float, y:Float, w:Float, h:Float, radius:Float, mode:DrawMode):Void {
		beginPath();
		moveTo(x + w * 0.5, y);
		arcTo(x + w, y, x + w, y + h * 0.5, radius);
		arcTo(x + w, y + h, x + w * 0.5, y + h, radius);
		arcTo(x, y + h, x, y + h * 0.5, radius);
		arcTo(x, y, x + w * 0.5, y, radius);
		closePath();
		switch mode {
			case Stroke:
				strokePath();
			case Fill:
				fillPath();
			case Both:
				fillPath();
				strokePath();
		}
	}

	extern public inline function text(s:String, x:Float, y:Float, mode:DrawMode, ?scale:Float = 1.0):Void {
		if (scale != 1.0) {
			c2d.save();
			c2d.translate(x, y);
			c2d.scale(scale, scale);
			text(s, 0, 0, mode, 1.0);
			c2d.restore();
			return;
		}
		switch mode {
			case Stroke:
				c2d.strokeText(s, x, y);
			case Fill:
				c2d.fillText(s, x, y);
			case Both:
				c2d.fillText(s, x, y);
				c2d.strokeText(s, x, y);
		}
	}

	extern public inline function translate(tx:Float, ty:Float):Void {
		c2d.translate(tx, ty);
	}

	extern public inline function scale(sx:Float, sy:Float):Void {
		c2d.scale(sx, sy);
	}

	extern public inline function rotate(ang:Float):Void {
		c2d.rotate(ang);
	}

	extern public inline function translated(tx:Float, ty:Float, draw:Void->Void):Void {
		saved(() -> {
			translate(tx, ty);
			draw();
		});
	}

	extern public inline function scaled(sx:Float, sy:Float, draw:Void->Void):Void {
		saved(() -> {
			scale(sx, sy);
			draw();
		});
	}

	extern public inline function rotated(ang:Float, draw:Void->Void):Void {
		saved(() -> {
			rotate(ang);
			draw();
		});
	}

	extern public inline function image(img:CanvasElement, x1:Float, y1:Float, ?w1:Float, ?h1:Float, ?x2:Float, ?y2:Float, ?w2:Float,
			?h2:Float):Void {
		if (x2 != null)
			c2d.drawImage(img, x1, y1, w1, h1, x2, y2, w2, h2);
		else if (w1 != null)
			c2d.drawImage(img, x1, y1, w1, h1);
		else
			c2d.drawImage(img, x1, y1);
	}

	extern public inline function scaledAt(sx:Float, sy:Float, x:Float, y:Float, draw:Void->Void):Void {
		saved(() -> {
			translate(x, y);
			scale(sx, sy);
			translate(-x, -y);
			draw();
		});
	}

	extern public inline function rotatedAt(ang:Float, x:Float, y:Float, draw:Void->Void):Void {
		saved(() -> {
			translate(x, y);
			rotate(ang);
			translate(-x, -y);
			draw();
		});
	}
}
