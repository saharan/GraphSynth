package graph;

@:using(graph.SocketType.SocketTypeTool)
enum SocketType {
	Normal(io:IO);
	Param(io:IO, name:String);
	Module(io:IO, boundary:Node);
}

class SocketTypeTool {
	public static function io(type:SocketType):IO {
		return switch (type) {
			case Normal(io): io;
			case Param(io, _): io;
			case Module(io, _): io;
		}
	}
}
