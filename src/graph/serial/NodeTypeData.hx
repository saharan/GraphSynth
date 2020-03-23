package graph.serial;

typedef NodeTypeData = {
	@:optional
	var normal:IOAbilityData;
	@:optional
	var module:IOAbilityData;
	@:optional
	var small:NullData;
	@:optional
	var boundary:IO;
}

typedef IOAbilityData = {
	var input:Bool;
	var output:Bool;
}
