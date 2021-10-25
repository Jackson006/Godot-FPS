extends Button

func _on_Button_pressed():
	Button.("pressed", self, "_on_Button_pressed",.create_sound("button_sound"))
