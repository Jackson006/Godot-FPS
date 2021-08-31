extends Control

var start_menu # A variable to hold the Start_Menu Panel
var level_select_menu # A variable to hold the Level_Select_Menu Panel
var options_menu #  A variable to hold the Options_Menu Panel

export (String, FILE) var testing_area_scene # The path to the Testing_Area.tscn file, so we can change to it from this scene
export (String, FILE) var space_level_scene # The path to the Space_Level.tscn file, so we can change to it from this scene
export (String, FILE) var ruins_level_scene # The path to the Ruins_Level.tscn file, so we can change to it from this scene
export (String, FILE) var doom_level_scene # The path to the Ruins_Level.tscn file, so we can change to it from this scene

func _ready():
	# gets all the Panel nodes and assign them to the proper variables
	# connects all the buttons pressed signals to their respective [panel_name_here]_button_pressed functions
	start_menu = $Start_Menu 
	level_select_menu = $Level_Select_Menu
	options_menu = $Options_Menu

	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Open_Godot.connect("pressed", self, "start_menu_button_pressed", ["open_godot"])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])

	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", self, "level_select_menu_button_pressed", ["testing_scene"])
	$Level_Select_Menu/Button_Level_Space.connect("pressed", self, "level_select_menu_button_pressed", ["space_level"])
	$Level_Select_Menu/Button_Level_Ruins.connect("pressed", self, "level_select_menu_button_pressed", ["ruins_level"])
	$Level_Select_Menu/Button_Doom_Level.connect("pressed", self, "level_select_menu_button_pressed", ["doom_level"])

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # sets the mouse mode to visible

	var globals = get_node("/root/Globals") # gets a singleton called globals
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity # Sets the values for HSlider
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity # Sets the values for HSlider

func start_menu_button_pressed(button_name):
	if button_name == "start": # Checks if the start button has been pressed
		level_select_menu.visible = true # makes the level select menu visible
		start_menu.visible = false # Makes the start meni invisible
	elif button_name == "open_godot": # checks to see if the open godot button has been pressed
		OS.shell_open("https://godotengine.org/") #
	elif button_name == "options": # Chcks if the options button has been pressed
		options_menu.visible = true # makes the options menu visible
		start_menu.visible = false # Makes the start menu invisible
	elif button_name == "quit": # Checks if the quit button has been pushed
		get_tree().quit() # quits the game


func level_select_menu_button_pressed(button_name):
	if button_name == "back": # Checks if the back button has been pushed
		start_menu.visible = true # Makes the start menu video
		level_select_menu.visible = false # makes the level select invisible
	elif button_name == "testing_scene": # Checks if the testing sceene button has been pushed
		set_mouse_and_joypad_sensitivity() # sets the mouse and joypad sensitivity
		get_node("/root/Globals").load_new_scene(testing_area_scene) # gets the node and loades a new scene
	elif button_name == "space_level": # Checks to see if the space level button has been pushed
		set_mouse_and_joypad_sensitivity() # sets the mouse and joypad sensitivity
		get_node("/root/Globals").load_new_scene(space_level_scene) # get node and load new scene
	elif button_name == "ruins_level": # Checks if the ruins level button has been pushed
		set_mouse_and_joypad_sensitivity() # sets the mouse and joypad sensitivity
		get_node("/root/Globals").load_new_scene(ruins_level_scene) # get node and load new scene
	elif button_name == "doom_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(doom_level_scene)


func options_menu_button_pressed(button_name):
	if button_name == "back": # Checks if the back button has been pushed 
		start_menu.visible = true # Makes the start menu visible
		options_menu.visible = false # Makes the options menu invisible
	elif button_name == "fullscreen": # Checks if the fullscreen button has been pushed
		OS.window_fullscreen = !OS.window_fullscreen # makes the game fullscreen
	elif button_name == "vsync": # checks if vsync has been pressed
		OS.vsync_enabled = $Options_Menu/Check_Button_VSync.pressed # 
	elif button_name == "debug":
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed) # call a new function called set_debug_display in our singleton
		pass


func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals") # makes globals a local variable
	# sets the mouse_sensitivity and joypad_sensitivity variables to the values in their respective HSlider node counterparts
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value # 
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value
