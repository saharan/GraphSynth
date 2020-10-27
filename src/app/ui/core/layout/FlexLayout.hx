package app.ui.core.layout;

using common.ArrayTools;
using common.FloatTools;
using common.IntTools;

class FlexLayout extends Layout {
	public var axis:Axis;

	public var alignMain:AlignMain = Start;
	public var alignCross:AlignCross = Stretch;
	public var alignInline:AlignInline = Stretch;

	public var lineWrap:LineWrap = None;

	public function new(axis:Axis) {
		super();
		this.axis = axis;
	}

	override function getContentSize(axis:Axis):Float {
		return if (axis == this.axis) {
			children.mapSum(c -> c.getBoundarySize(axis, 0, true));
		} else {
			children.mapMax(c -> c.getBoundarySize(axis, 0, true));
		}
	}

	override function getMinContentSize(axis:Axis):Float {
		return if (axis == this.axis) {
			if (lineWrap == None)
				children.mapSum(c -> c.getMinBoundarySize(axis, 0, true));
			else
				children.mapMax(c -> c.getMinBoundarySize(axis, 0, true));
		} else {
			0;
		}
	}

	override function getMaxContentSize(axis:Axis):Float {
		return Math.POSITIVE_INFINITY;
	}

	function determineLines():Array<Array<Element>> {
		if (lineWrap == None)
			return [children.copy()];
		var parentContentSize = target.contentSize(axis);
		var sizes = children.map(c -> c.getBoundarySize(axis, parentContentSize, true));
		var lines = [];
		var n = children.length;
		var index = 0;
		while (index < n) {
			var line = [];
			var leftSize = parentContentSize;
			do {
				var cand = children[index];
				if (line.length == 0 || sizes[index] <= leftSize) {
					line.push(cand);
					leftSize -= sizes[index];
					index++;
				} else {
					break;
				}
			} while (index < n);
			lines.push(line);
		}
		if (lineWrap == Reverse)
			lines.reverse();
		return lines;
	}

	static function justify(n:Int, contentSizes:Array<Float>, minSizes:Array<Float>, maxSizes:Array<Float>, grows:Array<Float>,
			shrinks:Array<Float>, autoMarginFlags:Array<Array<Bool>>, align:AlignMain, parentStart:Float, parentSize:Float,
			outStarts:Array<Float>, outSizes:Array<Float>):Void {
		var sizes = [for (i in 0...n) contentSizes[i].clamp(minSizes[i], maxSizes[i])];
		var sizesFixed = [for (i in 0...n) grows[i] == 0 && shrinks[i] == 0];

		var numAutoMargins = 0;
		for (a in autoMarginFlags) {
			if (a[0])
				numAutoMargins++;
			if (a[1])
				numAutoMargins++;
		}

		if (numAutoMargins > 0) {
			grows = grows.map(_ -> 0.0);
		}

		inline function computeFreeSpace():Float {
			var res = parentSize;
			for (s in sizes)
				res -= s;
			return res;
		}

		inline function distribute(value:Float):Bool {
			if (value == 0)
				return true;
			var denoms = value > 0 ? grows : shrinks;
			var denom = 0.0;
			for (i in 0...n) {
				if (!sizesFixed[i] && denoms[i] > 0)
					denom += denoms[i];
			}
			if (denom == 0)
				return true;
			value /= denom;
			var finished = true;
			for (i in 0...n) {
				if (!sizesFixed[i] && denoms[i] > 0) {
					sizes[i] += value * denoms[i];
					var size = sizes[i];
					var min = minSizes[i];
					var max = maxSizes[i];
					if (size < min || size > max) {
						finished = false;
						sizes[i] = size < min ? min : max;
						sizesFixed[i] = true;
					}
				}
			}
			return finished;
		}

		var freeSpace;
		do {
			freeSpace = computeFreeSpace();
		} while (!distribute(freeSpace));

		freeSpace = computeFreeSpace();
		if (freeSpace < 0)
			freeSpace = 0;

		var spaces = if (numAutoMargins > 0) {
			[for (i in 0...n + 1) {
				var count = 0;
				if (i > 0 && autoMarginFlags[i - 1][1])
					count++;
				if (i < n && autoMarginFlags[i][0])
					count++;
				freeSpace * count / numAutoMargins;
			}];
		} else {
			switch align {
				case Start:
					[for (i in 0...n + 1) i == n ? freeSpace : 0];
				case Center:
					[for (i in 0...n + 1) i == 0 || i == n ? freeSpace / 2 : 0];
				case End:
					[for (i in 0...n + 1) i == 0 ? freeSpace : 0];
				case SpaceBetween:
					[for (i in 0...n + 1) i == 0 || i == n ? 0 : freeSpace / (n - 1)];
				case SpaceAround:
					[for (i in 0...n + 1) (i == 0 || i == n ? 0.5 : 1) * freeSpace / n];
				case SpaceEvenly:
					[for (i in 0...n + 1) freeSpace / (n + 1)];
			}
		}

		var pos = parentStart + spaces[0];
		outStarts.resize(0);
		outSizes.resize(0);
		for (i in 0...n) {
			outStarts.push(pos);
			outSizes.push(sizes[i]);
			pos += sizes[i] + spaces[i + 1];
		}
	}

	static function processMainAxis(axis:Axis, line:Array<Element>, parentStart:Float, parentSize:Float, align:AlignMain):Void {
		var n = line.length;
		var styles = line.map(c -> c.style);

		// these includes margin
		var contentSizes = line.map(c -> c.getBoundarySize(axis, parentSize, true));
		var minSizes = line.map(c -> c.getMinBoundarySize(axis, parentSize, true));
		var maxSizes = line.map(c -> c.getMaxBoundarySize(axis, parentSize, true));
		var grows = styles.map(s -> s.grow);
		var shrinks = styles.map(s -> s.shrink);
		var autoMarginFlags = styles.map(s -> [s.margin.start(axis) == Auto, s.margin.end(axis) == Auto]);

		var starts = [];
		var sizes = [];

		justify(n, contentSizes, minSizes, maxSizes, grows, shrinks, autoMarginFlags, align, parentStart, parentSize, starts, sizes);

		for (i in 0...n) {
			var c = line[i];
			var margin = styles[i].margin;

			// consider margins
			var marginStart = margin.start(axis).toLength(Zero).calc(parentSize);
			var marginEnd = margin.end(axis).toLength(Zero).calc(parentSize);
			var start = starts[i] + marginStart;
			var size = sizes[i] - (marginStart + marginEnd);
			c.boundary.setAlong(axis, start, size);
		}
	}

	static function processCrossAxis(axis:Axis, lines:Array<Array<Element>>, parentStart:Float, parentSize:Float, alignCross:AlignCross,
			alignInline:AlignInline):Void {
		var n = lines.length;

		// these includes margin
		var contentSizes = lines.map(line -> line.mapMax(c -> c.getBoundarySize(axis, parentSize, true)).or(0));
		var minSizes = lines.map(line -> line.mapMax(c -> c.getMinBoundarySize(axis, parentSize, true)).or(0));
		var maxSizes = lines.map(line -> line.mapMax(c -> c.getMaxBoundarySize(axis, parentSize, true)).or(0));
		var align:AlignMain = switch alignCross {
			case Stretch | Start:
				Start;
			case Center:
				Center;
			case End:
				End;
			case SpaceBetween:
				SpaceBetween;
			case SpaceAround:
				SpaceAround;
			case SpaceEvenly:
				SpaceEvenly;
		}
		var grows = [for (i in 0...n) alignCross == Stretch ? 1.0 : 0.0];
		var shrinks = [for (i in 0...n) 1.0];
		var autoMarginFlags = [for (i in 0...n) [false, false]];
		var starts = [];
		var sizes = [];
		justify(n, contentSizes, minSizes, maxSizes, grows, shrinks, autoMarginFlags, align, parentStart, parentSize, starts, sizes);
		for (i in 0...n) {
			processInLine(axis, lines[i], starts[i], sizes[i], parentSize, alignInline);
		}
	}

	static function processInLine(axis:Axis, line:Array<Element>, lineStart:Float, lineSize:Float, parentSize:Float,
			defaultAlign:AlignInline):Void {
		var n = line.length;
		for (j in 0...n) {
			var c = line[j];

			// margin check
			var margin = c.style.margin;
			var margins = [margin.start(axis), margin.end(axis)];
			var autoMarginType = (margins[0] == Auto ? 1 : 0) | (margins[1] == Auto ? 2 : 0);
			var marginSizes = margins.map(m -> m.toLength(Zero).calc(parentSize));
			var marginSum = marginSizes[0] + marginSizes[1];
			var sizeSpecified = c.style.size.along(axis) != Auto;

			// compute align
			var align = c.style.alignInline.or(defaultAlign);
			switch (autoMarginType) {
				case 1:
					align = End;
				case 2:
					align = Start;
				case 3:
					align = Center;
			}

			// determine size
			var contentSize = c.getBoundarySize(axis, parentSize, false);
			var minSize = c.getMinBoundarySize(axis, parentSize, false);
			var maxSize = c.getMaxBoundarySize(axis, parentSize, false);
			var size = if (sizeSpecified) {
				contentSize;
			} else if (align == Stretch && autoMarginType == 0) {
				lineSize - marginSum;
			} else {
				(lineSize - marginSum).min(contentSize);
			}
			size = size.clamp(minSize, maxSize);

			// determine spaces
			var freeSpace = lineSize - (size + marginSum);
			var startSpace = switch align {
				case Stretch | Start:
					0;
				case Center:
					freeSpace / 2;
				case End:
					freeSpace;
			}

			// set
			c.boundary.setAlong(axis, lineStart + marginSizes[0] + startSpace, size);
		}
	}

	override function run() {
		var n = children.length;
		if (n == 0)
			return;
		var lines = determineLines();

		var cross = axis.cross();
		var innerStartMain = target.contentStart(axis);
		var innerSizeMain = target.contentSize(axis);
		var innerStartCross = target.contentStart(cross);
		var innerSizeCross = target.contentSize(cross);
		for (line in lines) {
			processMainAxis(axis, line, innerStartMain, innerSizeMain, alignMain);
		}
		processCrossAxis(cross, lines, innerStartCross, innerSizeCross, alignCross, alignInline);
	}
}
