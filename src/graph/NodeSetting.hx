package graph;

import synth.NumberData;
import graph.serial.NodeRoleData;
import graph.serial.NodeSettingData;
import synth.NodeRole;

class NodeSetting {
	public var name:String;
	public var role:NodeRole;

	public function new(name:String, role:NodeRole) {
		this.name = name;
		this.role = role;
	}

	public static function serializeRole(role:NodeRole):NodeRoleData {
		return switch (role) {
			case Frequency:
				{
					frequency: Null
				}
			case Oscillator(type):
				{
					oscillator: type
				}
			case Destination:
				{
					destination: Null
				}
			case Delay:
				{
					delay: Null
				}
			case Filter(type):
				{
					filter: type
				}
			case Compressor:
				{
					compressor: Null
				}
			case Envelope(env):
				{
					envelope: {
						a: env.a,
						d: env.d,
						s: env.s,
						r: env.r
					}
				}
			case Number(num):
				{
					number: num.value
				}
			case BinOp(type):
				{
					binOp: type
				}
			case Dupl:
				{
					dupl: Null
				}
			case None:
				{
					none: Null
				}
		}
	}

	public static function deserializeRole(data:NodeRoleData):NodeRole {
		var count = 0;
		if (data.frequency != null)
			count++;
		if (data.oscillator != null)
			count++;
		if (data.destination != null)
			count++;
		if (data.delay != null)
			count++;
		if (data.filter != null)
			count++;
		if (data.compressor != null)
			count++;
		if (data.envelope != null)
			count++;
		if (data.number != null)
			count++;
		if (data.binOp != null)
			count++;
		if (data.dupl != null)
			count++;
		if (data.none != null)
			count++;
		if (count != 1)
			throw "invalid node role data: " + data;
		if (data.frequency != null)
			return Frequency;
		if (data.oscillator != null)
			return Oscillator(data.oscillator);
		if (data.destination != null)
			return Destination;
		if (data.delay != null)
			return Delay;
		if (data.filter != null)
			return Filter(data.filter);
		if (data.compressor != null)
			return Compressor;
		if (data.envelope != null)
			return Envelope(new synth.EnvelopeData(data.envelope.a, data.envelope.d, data.envelope.s, data.envelope.r));
		if (data.number != null)
			return Number(new NumberData(data.number));
		if (data.binOp != null)
			return BinOp(data.binOp);
		if (data.dupl != null)
			return Dupl;
		if (data.none != null)
			return None;
		throw "!?";
	}

	public function serialize():NodeSettingData {
		return {
			name: name,
			role: serializeRole(role)
		}
	}

	public static function deserialize(data:NodeSettingData):NodeSetting {
		return new NodeSetting(data.name, deserializeRole(data.role));
	}
}
