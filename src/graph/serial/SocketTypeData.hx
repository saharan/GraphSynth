package graph.serial;

typedef SocketTypeData = {
	@:optional
	var normal:IO;
	@:optional
	var param:Param;
	@:optional
	var module:Module;
}

typedef Param = {
	var io:IO;
	var name:String;
}

typedef Module = {
	var io:IO;
	var boundaryNode:Int;
}
