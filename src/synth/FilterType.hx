package synth;

enum abstract FilterType(String) {
	var LowPass = "lp";
	var HighPass = "hp";
	var BandPass = "bp";
	var BandStop = "bs";
	var LowShelf = "ls";
	var HighShelf = "hs";
	var Peak = "p";
}
