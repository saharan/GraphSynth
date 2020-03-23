package synth;

import graph.BinOpType;
import graph.serial.NodeRoleData;
import synth.EnvelopeData;

@:using(synth.NodeRole.NodeRoleTools)
enum NodeRole {
	Frequency;
	Oscillator(type:OscillatorType);
	Destination;
	Delay;
	Filter(type:FilterType);
	Compressor;
	Envelope(env:EnvelopeData);
	Number(num:NumberData);
	BinOp(type:BinOpType);
	Dupl;
	None;
}

class NodeRoleTools {
	public static inline function copy(role:NodeRole):NodeRole {
		switch (role) {
			case Envelope(env):
				return Envelope(new EnvelopeData(env.a, env.d, env.s, env.r));
			case Number(num):
				return Number(new NumberData(num.value));
			case _:
				return role;
		}
	}
}
