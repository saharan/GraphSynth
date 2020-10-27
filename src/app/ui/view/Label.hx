package app.ui.view;

import app.ui.view.color.StaticColor;
import app.ui.view.color.Color;
import app.graphics.DrawMode;
import app.graphics.Graphics;
import app.graphics.TextAlign;
import app.ui.core.LengthOrAuto;

class Label extends Sprite {
	var text:Gen<String>;
	var scale:Gen<Float>;
	var align:TextAlign;

	public var fill:Bool = true;
	public var fillColor:Color = StaticColor.black();

	public var stroke:Bool = false;
	public var strokeWidth:Float = 0.8;
	public var strokeColor:Color = StaticColor.black();

	public function new(text:Gen<String>, align:TextAlign, w:LengthOrAuto, h:LengthOrAuto, scale:Gen<Float>) {
		super();
		this.text = text;
		this.scale = scale;
		this.align = align;
		style.size.set(w, h);
	}

	override function draw(g:Graphics) {
		var drawMode:DrawMode = fill ? stroke ? Both : Fill : Stroke;
		g.fill(fillColor.r, fillColor.g, fillColor.b, fillColor.a);
		g.stroke(strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a);
		g.textAlign(align);
		g.textBaseline(Middle);
		var scale:Float = scale;
		g.lineWidth(strokeWidth / scale);
		switch align {
			case Left:
				g.text(text, 0, height * 0.5, drawMode, scale);
			case Right:
				g.text(text, width, height * 0.5, drawMode, scale);
			case Center:
				g.text(text, width * 0.5, height * 0.5, drawMode, scale);
		}
	}
}
