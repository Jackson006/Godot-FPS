extends Node

var mouse_sensitivity = 0.05 # The current sensitivity for our mouse, so we can load it in
var joypad_sensitivity = 2 # The current sensitivity for our joypad, so we can load it in

var canvas_layer = null # A canvas layer so the GUI/UI created in Globals.gd is always drawn on top

const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn") # The debug display scene we worked on earlier
var debug_display = null # A variable to hold the debug display when/if there is one

const MAIN_MENU_PATH = "res://Main_Menu.tscn" # The path to the main menu scene
const POPUP_SCENE = preload("res://Pause_Popup.tscn") # The pop up scene we looked at earlier
var popup = null # A variable to hold the pop up scene

func _ready():
	canvas_layer = CanvasLayer.new() # creates a new canvas layer
	add_child(canvas_layer)

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path) # changes the scene

func set_debug_display(display_on):
	if display_on == false: # checks to see of the display equals false
		if debug_display != null: # checks to see if the display equals null
			debug_display.queue_free() # deletes the debug display
			debug_display = null # makes the debug deisplay equal null
	else:
		if debug_display == null: # checks to see if the display equals null
			debug_display = DEBUG_DISPLAY_SCENE.instance() # 
			canvas_layer.add_child(debug_display)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"): # checks if the cancel button has been pressed
		if popup == null: # Checks if popup equals null
			popup = POPUP_SCENE.instance() # makes popup equal scene instance

			popup.get_node("Button_quit").connect("pressed", self, "popup_quit") # get the quit button and assign its pressed signal to popup_quit
			popup.connect("popup_hide", self, "popup_closed") # assign both the popup_hide signal from the WindowDialog and the pressed signal from the resume button to popup_closed
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed") # add popup as a child of canvas_layer so it's drawn on top

			canvas_layer.add_child(popup) # tells popup to pop up at the center of the screen using popup_centered
			popup.popup_centered()

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # makes sure the mouse mode is MOUSE_MODE_VISIBLE

			get_tree().paused = true # pauses the entire SceneTree

func popup_closed():
	get_tree().paused = false # pauses the tree

	if popup != null: # Checks if popup equals null
		popup.queue_free() # Deltes the popup
		popup = null # makes the popup equals null

func popup_quit():
	get_tree().paused = false # pauses the tree

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # makes the mouse visible

	if popup != null: # Checks if popup equals null
		popup.queue_free() # deletes the popup
		popup = null # popup equals null

	load_new_scene(MAIN_MENU_PATH) # loads new scene
