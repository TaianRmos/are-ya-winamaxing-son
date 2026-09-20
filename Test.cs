using Godot;
using System;

public partial class Test : Control
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GD.Print("Hello from C#");
	}
}
