	extends KinematicBody

const GRAVITY = -50 # How strong gravity pulls down
var vel = Vector3() # The Kinematic body's velocity
const MAX_SPEED = 30 # The max speed the kinematic body can reach without sprinting
const JUMP_SPEED = 27 # How high the kinematic body can jump
const ACCEL = 7 # How quickly we can reach the max walking speed

const MAX_SPRINT_SPEED = 50 # The max speed the kinematic body can reach while sprinting
const SPRINT_ACCEL = 18 # How quickly the max sprint speed can be reached
var is_sprinting = false # a boolean to track whether the player is currently sprinting

var flashlight # the variable that hold's the player's flash light node

var dir = Vector3()

const DEACCEL= 16 # How quickly the kniematic body can completely stop
const MAX_SLOPE_ANGLE = 40 # The steepest angle the kinematic body sees as floor

var camera # the camera node
var rotation_helper # holds everything on the x-axis in place

var MOUSE_SENSITIVITY = 0.5 # The sensitivity of the mouse in game

var animation_manager # holds the animation player node and its script

var current_weapon_name = "UNARMED" # The name of the weapon currently being used
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null} # A dictionary that hods the weapon nodes
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"} # A dictionary that converts a weapon's number to its name (helpful for changing weapons)
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3} # A dictionary that converts a weapon's name to its number (helpful for changing weapons)
var changing_weapon = false # a boolean to track whether or not we are changing weapons
var changing_weapon_name = "UNARMED" #The name of the weapon we want to change to 

var health = 100 # the health of the player

var UI_status_label # A label to show how much health we have, and how much ammo we have in our gun and in reserve

var reloading_weapon = false

var simple_audio_player = preload("res://Simple_Audio_Player.tscn")

func create_sound(sound_name, position=null):
	var audio_clone = simple_audio_player.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(audio_clone)
	audio_clone.play_sound(sound_name, position)

func _ready():
	camera = $Rotation_Helper/Camera #
	rotation_helper = $Rotation_Helper

	animation_manager = $Rotation_Helper/Model/Animation_Player 
	animation_manager.callback_function = funcref(self, "fire_bullet") # calls the player's fire bullet function

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Assigns all of the weapons as actual weapons, this allows us to access the weapon nodes with only their names
	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point

	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin # let's us rotate the player's weapons to aim at it

	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null: # If the weapon node is not null, we then set its player_node variable to this script
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0)) # rotates the gun's aim
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))

# current weapons being used are none
	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"

# The UI label from the HUD
	UI_status_label = $HUD/Panel/Gun_label
	flashlight = $Rotation_Helper/Flashlight # get's the flashlight noed and assigns it to the variable

func _physics_process(delta):
	process_input(delta) # input controls eg. spacebar WASD
	process_movement(delta) # player movement 
	process_changing_weapons(delta) # Weapon changing
	process_UI(delta) # What is shown to the player in the form as a HUD
	process_reloading(delta) # Reloading the weapons

func process_reloading(delta):
	if reloading_weapon == true:
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			current_weapon.reload_weapon()
		reloading_weapon = false

func process_UI(delta):
	if current_weapon_name == "UNARMED" or current_weapon_name == "KNIFE": # check to see if the current weapon is unarmed or knife
		UI_status_label.text = "HEALTH: " + str(health) # If the current weapon is unarmed/knife, only display the player's health
	else: # get the name of the weapon being used, display health and weapin information
		var current_weapon = weapons[current_weapon_name]  
		UI_status_label.text = "HEALTH: " + str(health) + \
			"\nAMMO: " + str(current_weapon.ammo_in_weapon) + "/" + str(current_weapon.spare_ammo) 

func process_changing_weapons(delta):
	if changing_weapon == true: # has there been an input to change weapons

		var weapon_unequipped = false # checks to see whether the weapon was succesfulley equipped
		var current_weapon = weapons[current_weapon_name] # finds the current weapon being used

		if current_weapon == null: # Cheks whether the weapon is enabled
			weapon_unequipped = true # calls the unequip weapon function
		else:
			if current_weapon.is_weapon_enabled == true: 
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true
	
		if weapon_unequipped == true: # if the player has successfully unequipped the weapon
	
			var weapon_equipped = false #new variable for tracking equipped guns
			var weapon_to_equip = weapons[changing_weapon_name] # The weapon the player wants to change to
	
			if weapon_to_equip == null: # checks to see whether or not the weapon is enabled
				weapon_equipped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equipped = weapon_to_equip.equip_weapon()
				else:
					weapon_equipped = true
	
				if weapon_equipped == true: # check to see if the player has successfully equipped the weapon
					changing_weapon = false
					current_weapon_name = changing_weapon_name
					changing_weapon_name = ""

func fire_bullet(): # plays the appropriate animation of the bullet
	if changing_weapon == true:
		return

	weapons[current_weapon_name].fire_weapon()

func process_input(delta):
# ----------------------------------
# Reloading
	if reloading_weapon == false:
		if changing_weapon == false:
			if Input.is_action_just_pressed("reload"):
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.CAN_RELOAD == true:
						var current_anim_state = animation_manager.current_state
						var is_reloading = false
						for weapon in weapons:
							var weapon_node = weapons[weapon]
							if weapon_node != null:
								if current_anim_state == weapon_node.RELOADING_ANIM_NAME:
									is_reloading = true
						if is_reloading == false:
							reloading_weapon = true
# ----------------------------------
# ----------------------------------
# Firing the weapons
	if Input.is_action_pressed("fire"):
		if reloading_weapon == false:
			if changing_weapon == false:
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.ammo_in_weapon > 0:
						if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
							animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
					else:
						reloading_weapon = true
# ----------------------------------
# ----------------------------------
# Firing the weapons
	if Input.is_action_pressed("fire"):
		if changing_weapon == false:
			var current_weapon = weapons[current_weapon_name]
			if current_weapon != null:
				if current_weapon.ammo_in_weapon > 0:
					if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
						animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
# ----------------------------------
# ----------------------------------
# Changing weapons.
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name] # get's the current weapon's number and assigns it to this function

# the key map values
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 3

# checks to see is the weapon is being changed or not
	if Input.is_action_just_pressed("shift_weapon_positive"): # adds 
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"): # subtracts 
		weapon_change_number -= 1

	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size() - 1) # The mximum number of weapons the player can chose from

	if changing_weapon == false: #Checks to see if the player is changing weapons
		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name: # Check to see if the player wants to change weapons
			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
			changing_weapon = true # if the payer wants to change weapons, change to true
	if changing_weapon == false:
		if reloading_weapon == false:
			if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
				changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
				changing_weapon = true
# ----------------------------------

# ----------------------------------
# Firing the weapons
	if Input.is_action_pressed("fire"): # Checks to see if the fire button has been pressed
		if changing_weapon == false: #Checks to see if the player is changing weapons 
			var current_weapon = weapons[current_weapon_name] # gets the node for the current weapon
			if current_weapon != null:
				if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME: # Happens if the player is not moving 
					animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
# ----------------------------------


	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"): # when this is true the player is sprinting
		is_sprinting = true
	else: # When this is false the player isn't sprinting
		is_sprinting = false
# ----------------------------------

# ----------------------------------
# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"): # When the flashlight action button is pressed turn the flashlight on
		if flashlight.is_visible_in_tree():
			flashlight.hide() # When this is false turn the flashlight off
		else: 
			flashlight.show()
# ----------------------------------

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"): # The forward movement speed of the kinematic body
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"): # The backward movement speed of the kinematic body
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"): # The left movement speed of the kinematic body
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"): # The right movement speed of the kinematic body
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized() # The virtual axis

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	dir.y = 0 # ensures that dir does not have any movement on the y-axis
	dir = dir.normalized() # Makes sure we're moving at a  constant speed

	vel.y += delta * GRAVITY # adds gravity to the player's velocity

	var hvel = vel # assigns velocity to a new variable
	hvel.y = 0

	var target = dir # let's us know how far the player is moving in a direction
	if is_sprinting: 
			target *= MAX_SPRINT_SPEED # the sprinting speed
	else:
			target *= MAX_SPEED # the walking speed

	var accel # determines the accelerator dependent on whether the player is sprinting or not
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
				accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta) # Checks to see which direction the player is moving in
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event): # keeps the mouse on the screen
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
