package graph.serial;

typedef NodeData = {
	var x:Fixed;
	var y:Fixed;
	var type:NodeTypeData;
	var setting:NodeSettingData;
	var sockets:Array<SocketData>;
	@:optional
	var graph:GraphData;
	@:optional
	var boundaries:Array<Int>;
}
