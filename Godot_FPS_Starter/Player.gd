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
const MAX_HEALTH = 150 # The maximum amount of health a player can have

var UI_status_label # A label to show how much health we have, and how much ammo we have in our gun and in reserve

var reloading_weapon = false # A variable to track whether or not the player is currently trying to reload

var simple_audio_player = preload("res://Simple_Audio_Player.tscn") # A variable to place the audio scene

var JOYPAD_SENSITIVITY = 2 # how fast the joysticks will move the camera
const JOYPAD_DEADZONE = 0.15 # The deadzone of the joypad

var mouse_scroll_value = 0 # The value of the mouse scroll wheel
const MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.08 # How much a single scroll action increases mouse_scroll_value

var grenade_amounts = {"Grenade":2, "Sticky Grenade":2} # The amount of grenades the player is currently carrying (for each type of grenade
var current_grenade = "Grenade" # The name of the grenade the player is currently using
var grenade_scene = preload("res://Grenade.tscn") # The grenade scene we worked on earlier
var sticky_grenade_scene = preload("res://Sticky_Grenade.tscn") # The sticky grenade scene we worked on earlier
const GRENADE_THROW_FORCE = 50 # The force at which the player will throw the grenades

func add_health(additional_health):
	health += additional_health # adds additional health onto the player
	health = clamp(health, 0, MAX_HEALTH) # stops their health from rising above a certain level

func add_ammo(additional_ammo):
	if (current_weapon_name != "UNARMED"): # Checks whether the player is unarmed
		if (weapons[current_weapon_name].CAN_REFILL == true): # checks to see if the current weapon can be refilled
			weapons[current_weapon_name].spare_ammo += weapons[current_weapon_name].AMMO_IN_MAG * additional_ammo # adds a full clip/magazine worth of ammo to the weapon by multiplying the current weapon's AMMO_IN_MAG value

func create_sound(sound_name, position=null):
	var audio_clone = simple_audio_player.instance() # instances the audio scene and assigns it a variable
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(audio_clone) # adds newly created simple_audio_player scene to be a child of the scene root
	audio_clone.play_sound(sound_name, position) # play's the designated audio

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
	process_view_input(delta)

func process_view_input(delta):
# ----------------------------------
# Joypad rotation

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED: # checks mouse mode
		return

	var joypad_vec = Vector2() # define vector2 to hold the right joystick position
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows" or OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE: # account for the joypad's deadzone
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		rotation_helper.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY)) # rotates rotation_helper and the player's KinematicBody using joypad_vec 

		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
# ----------------------------------

func process_reloading(delta):
	if reloading_weapon == true: # checks to see if the player is trying to reload
		var current_weapon = weapons[current_weapon_name] # checks the name of the current weapon 
		if current_weapon != null: # if it is not null, reload the weapon
			current_weapon.reload_weapon()
		reloading_weapon = false # Once the player has reloaded, do not try to reload until the player presses the reload button

func process_UI(delta):
	if current_weapon_name == "UNARMED" or current_weapon_name == "KNIFE":
		# First line: Health, second line: Grenades
		UI_status_label.text = "HEALTH: " + str(health) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])
	else:
		var current_weapon = weapons[current_weapon_name]
		# First line: Health, second line: weapon and ammo, third line: grenades
		UI_status_label.text = "HEALTH: " + str(health) + \
				"\nAMMO: " + str(current_weapon.ammo_in_weapon) + "/" + str(current_weapon.spare_ammo) + \
				"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade]) 

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
# Changing and throwing grenades

	if Input.is_action_just_pressed("change_grenade"): # has the change grenade button been pushed
		if current_grenade == "Grenade": # checks if the current grenade is the regular grenade
			current_grenade = "Sticky Grenade" # Changes grenade to opposite grenade
		elif current_grenade == "Sticky Grenade": # checks if the current grenade is sticky grenade
			current_grenade = "Grenade" # changes grenade to opposite grenade

		if Input.is_action_just_pressed("fire_grenade"): # has fire grenade been pressed
			if grenade_amounts[current_grenade] > 0: # checks if the number of grenades is greater than 0
				grenade_amounts[current_grenade] -= 1 # reduces the number of grenades by 1

			var grenade_clone # creates a grenade node 
			if current_grenade == "Grenade": # checks if the current grenade is the regular grenade
				grenade_clone = grenade_scene.instance() # generates an instance of the current grenade
			elif current_grenade == "Sticky Grenade": # checks if the current grenade is the sticky grenade
				grenade_clone = sticky_grenade_scene.instance() # generates an instance of the current grenade
				# Sticky grenades will stick to the player if we do not pass ourselves
				grenade_clone.player_body = self

			get_tree().root.add_child(grenade_clone) # generates grenade clone as a child node at the root node
			grenade_clone.global_transform = $Rotation_Helper/Grenade_Toss_Pos.global_transform # sets the global transform
			grenade_clone.apply_impulse(Vector3(0, 0, 0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE) # lanches the grenade forward
# ----------------------------------
# ----------------------------------
# Reloading
	if reloading_weapon == false: # makes sure that the player isn't reloading or changing weapons
		if changing_weapon == false: # if the player isn't reloading or changing weapons run the following code
			if Input.is_action_just_pressed("reload"): # Checks to see if the reload button has been pressed
				var current_weapon = weapons[current_weapon_name] # Checks the name of the weapon
				if current_weapon != null: 
					if current_weapon.CAN_RELOAD == true: # checks if the weapon can be reloaded
						var current_anim_state = animation_manager.current_state # checks the current animation state
						var is_reloading = false # a variable to see if the weapon is currently being reloaded
						for weapon in weapons: # Checks the animation states of other weapons
							var weapon_node = weapons[weapon]
							if weapon_node != null:
								if current_anim_state == weapon_node.RELOADING_ANIM_NAME: # If the player is not reloading any weapon, set reloading weapon to true
									is_reloading = true
						if is_reloading == false: 
							reloading_weapon = true
# ----------------------------------
# ----------------------------------
# Firing the weapons
	if Input.is_action_pressed("fire"): # checks to see if the "fire" button has been pressed
		if reloading_weapon == false: # Checks to see if the weapon is being reloaded
			if changing_weapon == false: # checks to see if the player is changing weapons
				var current_weapon = weapons[current_weapon_name] # a variable to check the current weapon's name
				if current_weapon != null: 
					if current_weapon.ammo_in_weapon > 0: # checks to see if there is not ammo in the weapon
						if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME: # checks to see if the gun in idle animation
							animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME) # plays the fire animation
					else:
						reloading_weapon = true # reloads the weapon
# ----------------------------------
# ----------------------------------
# Changing weapons.
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name] # get's the current weapon's number and assigns it to this function

# the key map values
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 3
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 4

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
			mouse_scroll_value = weapon_change_number
	if changing_weapon == false: # if the player is not changing weapons
		if reloading_weapon == false: # The player cannot change weapons if they are reloding 
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

	if Input.get_connected_joypads().size() > 0: # checks to see if there is a connected joypad

			var joypad_vec = Vector2(0, 0) # get left stick axes for right/left and up/down

			if OS.get_name() == "Windows" or OS.get_name() == "X11":
				joypad_vec = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
			elif OS.get_name() == "OSX":
				joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))

			if joypad_vec.length() < JOYPAD_DEADZONE: # checks to see if the joypad vector length is within the JOYPAD_DEADZONE radius
				joypad_vec = Vector2(0, 0) # If it is, set joypad_vec to an empty Vector2
			else: # If it is not, use a scaled Radial Dead zone
				joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

			input_movement_vector += joypad_vec # add joypad vec to input_movement_vector

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

	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # checks if the event is an InputEventMouseButton event and that the mouse mode is MOUSE_MODE_CAPTURED
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN: # checks to see if the button index is either a Button_wheel_up or Button_wheel_down
			if event.button_index == BUTTON_WHEEL_UP: # Based on whether it is up or down, add or subtract MOUSE_SENSITIVITY_SCROLL_WHEEL to/from mouse_scroll_value
				mouse_scroll_value += MOUSE_SENSITIVITY_SCROLL_WHEEL
			elif event.button_index == BUTTON_WHEEL_DOWN:
				mouse_scroll_value -= MOUSE_SENSITIVITY_SCROLL_WHEEL

			mouse_scroll_value = clamp(mouse_scroll_value, 0, WEAPON_NUMBER_TO_NAME.size() - 1) # clamps mouse scroll value

			if changing_weapon == false: # checks to see if the player is changing weapons
				if reloading_weapon == false: #checks to see if the player is reloading
					var round_mouse_scroll_value = int(round(mouse_scroll_value)) # rounds mouse_scroll_value and casts it to an int
					if WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] != current_weapon_name: # checks  to see if the weapon name at round_mouse_scroll_value is not equal to the current weapon name using WEAPON_NUMBER_TO_NAME
						changing_weapon_name = WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] # assign changing_weapon_name to true so that so the player will change weapons
						changing_weapon = true
						mouse_scroll_value = round_mouse_scroll_value

func add_grenade(additional_grenade):
	grenade_amounts[current_grenade] += additional_grenade
	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)
