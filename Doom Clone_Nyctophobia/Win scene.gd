extends Control

# when buttons are pressed in this scene, load the scene coded on the button
func _ready():
	for button in $HUD.get_children(): # no problems
		button.connect("pressed", self, "_on_Button_pressed",[button.scene_to_load])

# when buttons are pressed in this scene, load the scene coded on the button
func _on_Button_pressed(scene_to_load):
	print("Changing Scene...")
	print(scene_to_load)
	get_tree().change_scene(scene_to_load)
