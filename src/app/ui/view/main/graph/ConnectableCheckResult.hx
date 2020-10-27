package app.ui.view.main.graph;

import graph.Vertex;
import graph.Socket;
import graph.Node;

@:using(app.ui.view.main.graph.ConnectableCheckResult.ConnectableCheckResultTools)
enum ConnectableCheckResult {
	Ignore;
	TryNode(n:Node, ok:Bool);
	TrySocket(s:Socket, ok:Bool);
	TryCable(v:Vertex, ok:Bool);
}

class ConnectableCheckResultTools {
	public static function ok(res:ConnectableCheckResult):Bool {
		return switch res {
			case Ignore:
				false;
			case TryNode(_, ok):
				ok;
			case TrySocket(_, ok):
				ok;
			case TryCable(_, ok):
				ok;
		}
	}

	public static function vertex(res:ConnectableCheckResult):Vertex {
		return switch res {
			case Ignore:
				null;
			case TryNode(n, _):
				n.phys.vertex;
			case TrySocket(s, _):
				s.phys.vertex;
			case TryCable(v, _):
				v;
		}
	}
}
