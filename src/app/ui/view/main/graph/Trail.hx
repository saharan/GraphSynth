package app.ui.view.main.graph;

import common.Set;
import graph.Graph;
import graph.Vertex;
import graph.Edge;
import haxe.ds.ArraySort;
import graph.Node;

class Trail {
	public final poss:Array<TrailPos> = [];

	public var isLasso(default, null):Bool = false;

	public function new() {
	}

	public function clear():Void {
		poss.resize(0);
		isLasso = false;
	}

	public function begin(x:Float, y:Float):Void {
		clear();
		poss.push([x, y]);
	}

	public function move(x:Float, y:Float, currentViewScale:Float):Void {
		assertNonEmpty();
		if (poss.length == 1) {
			// add the second point
			poss.push([x, y]);
			return;
		}
		// rewrite last pos
		poss.pop();
		var last = lastPos();
		poss.push([x, y]);
		if (last.dist(lastPos()) * currentViewScale > ClickSettings.TRAIL_INTERVAL_PX) {
			// the next pos to be modified
			poss.push([x, y]);
		}

		// lasso check
		isLasso = false;
		if (poss.length >= ClickSettings.LASSO_LEAST_VERTEX_COUNT) {
			var first = firstPos();

			var maxDist = 0.0;
			for (p in poss) {
				var dist = p.dist(first);
				if (dist > maxDist)
					maxDist = dist;
			}

			var last = lastPos();
			if (first.dist(last) < maxDist * ClickSettings.LASSO_CLOSE_THRESHOLD_RATIO) {
				isLasso = true;
			}
		}
	}

	public function firstPos():TrailPos {
		assertNonEmpty();
		return poss[0];
	}

	public function lastPos():TrailPos {
		assertNonEmpty();
		return poss[poss.length - 1];
	}

	public inline function forEachInternalPos(f:TrailPos->Void):Void {
		assertNonEmpty();
		for (i in 1...poss.length - 1) {
			f(poss[i]);
		}
	}

	public function getSlashedVertices(nodes:Array<Node>, vertices:Array<Vertex>):Array<Vertex> {
		var res = [];
		for (v in vertices) {
			var radius = switch v.type {
				case Node(n):
					n.getRadius() * 0.6;
				case Socket(_):
					-1;
				case Normal:
					Graph.CABLE_LENGTH * 0.6;
			}
			if (radius < 0)
				continue;
			var cut = false;
			var px = v.point.x;
			var py = v.point.y;
			for (i in 1...poss.length) {
				var v1 = poss[i - 1];
				var v2 = poss[i];
				var x1 = v1.x;
				var y1 = v1.y;
				var x2 = v2.x;
				var y2 = v2.y;
				var dist = segmentPointDist(x1, y1, x2, y2, px, py);
				if (dist < radius) {
					cut = true;
					break;
				}
			}
			if (cut)
				res.push(v);
		}
		return res;
	}

	inline function segmentPointDist(x1:Float, y1:Float, x2:Float, y2:Float, px:Float, py:Float):Float {
		var ax = px - x1;
		var ay = py - y1;
		var dx = x2 - x1;
		var dy = y2 - y1;
		var dd = dx * dx + dy * dy;
		if (dd > 1e-6) {
			var t = (ax * dx + ay * dy) / dd;
			if (t < 0)
				t = 0;
			else if (t > 1)
				t = 1;
			var cx = x1 + t * dx;
			var cy = y1 + t * dy;
			ax = px - cx;
			ay = py - cy;
		}
		return Math.sqrt(ax * ax + ay * ay);
	}

	public function selectByLasso(selection:Selection, nodes:Array<Node>):Void {
		if (!isLasso)
			throw "not lasso";
		var vertices = poss.copy();
		var numV = vertices.length;
		var edges = [];
		var points:Array<LassoSweepPoint> = [];
		for (i in 0...vertices.length) {
			var i1 = i;
			var i2 = (i + 1) % numV;
			if (vertices[i1].y > vertices[i2].y) {
				var tmp = i1;
				i1 = i2;
				i2 = tmp;
			}
			edges.push([i1, i2]);
			points.push(LineBegin(i, i1));
			points.push(LineEnd(i, i2));
		}
		for (i in 0...nodes.length) {
			var n = nodes[i];
			points.push(NodeCenter(i, n.phys.vertex.point.x, n.phys.vertex.point.y));
		}
		// sort must be stable
		ArraySort.sort(points, (p1, p2) -> {
			var y1 = switch p1 {
				case LineBegin(_, vertex):
					vertices[vertex].y;
				case LineEnd(_, vertex):
					vertices[vertex].y;
				case NodeCenter(_, _, y):
					y;
			}
			var y2 = switch p2 {
				case LineBegin(_, vertex):
					vertices[vertex].y;
				case LineEnd(_, vertex):
					vertices[vertex].y;
				case NodeCenter(_, _, y):
					y;
			}
			return y1 < y2 ? -1 : y1 > y2 ? 1 : 0;
		});
		var edgeIndices = [];
		var counts = [for (_ in nodes) 0];
		for (p in points) {
			switch p {
				case LineBegin(index, vertex):
					edgeIndices.push(index);
				case LineEnd(index, vertex):
					edgeIndices.remove(index);
				case NodeCenter(ni, x, y):
					for (edge in edgeIndices) {
						var v1 = vertices[edges[edge][0]];
						var v2 = vertices[edges[edge][1]];
						if (v1.y != v2.y) {
							var crossX = v1.x + (v2.x - v1.x) * (y - v1.y) / (v2.y - v1.y);
							if (crossX > x)
								counts[ni]++;
						}
					}
			}
		}
		selection.clear();
		for (i in 0...counts.length) {
			if (counts[i] % 2 == 1)
				selection.add(nodes[i]);
		}
	}

	function assertNonEmpty():Void {
		if (poss.length == 0)
			throw "trail is empty";
	}
}
