extends Control

func _ready():
	$OS_Label.text = "OS: " + OS.get_name() # set the OS_Label's text to the name provided by OS using the get_name function
	$Engine_Label.text = "Godot version: " + Engine.get_version_info()["string"] # 

func _process(delta):
	$FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second())
