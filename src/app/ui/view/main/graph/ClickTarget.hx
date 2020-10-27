package app.ui.view.main.graph;

import graph.Node;
import graph.Socket;
import graph.Vertex;

enum ClickTarget {
	Node(n:Node);
	Socket(s:Socket);
	CableVertex(v:Vertex);
	None;
}