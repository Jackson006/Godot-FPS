extends Spatial

export (int, "full size", "small") var kit_size = 0 setget kit_size_change #The size of the health pickup

# 0 = full size pickup, 1 = small pickup
const HEALTH_AMOUNTS = [70, 30] # The amount of health each pickup in each size contains

const RESPAWN_TIME = 20 # The amount of time, in seconds, it takes for the health pickup to respawn
var respawn_timer = 0 # A variable used to track how long the health pickup has been waiting to respawn

var is_ready = false # A variable to track whether the ready function has been called or not

func _ready():

	$Holder/Health_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered") # connects the body entered signal to the trigger body entered function

	is_ready = true # enables the setget function

# hides all possible kits using the values
	kit_size_change_values(0, false)
	kit_size_change_values(1, false)
	kit_size_change_values(kit_size, true) # makes only the selected kit size visible


func _physics_process(delta):
	if respawn_timer > 0: # 
		respawn_timer -= delta

		if respawn_timer <= 0:
			kit_size_change_values(kit_size, true)


func kit_size_change(value):
	if is_ready: # Checks to see if is_ready is true
		kit_size_change_values(kit_size, false) # disables the kit assigned to kit size using the kit size change values
		kit_size = value # Assings kit size to a new value
		kit_size_change_values(kit_size, true) # calls kit size change values as true
	else:
		kit_size = value # assigns kit size to pass if is_ready is not true 


func kit_size_change_values(size, enable):
	if size == 0: # checks to see which size was passed in
		$Holder/Health_Pickup_Trigger/Shape_Kit.disabled = !enable # get the collision shape for the node corresponding to the size 
		$Holder/Health_Kit.visible = enable # sets the visibility of the spatial node to visible
	elif size == 1:  
		$Holder/Health_Pickup_Trigger/Shape_Kit_Small.disabled = !enable # disables the proper nodes for size
		$Holder/Health_Kit_Small.visible = enable


func trigger_body_entered(body):
	if body.has_method("add_health"): # Checks if the body has entered the function
		body.add_health(HEALTH_AMOUNTS[kit_size]) # Calls add health 
		respawn_timer = RESPAWN_TIME # Sets the repawn timer
		kit_size_change_values(kit_size, false) # Makes the kit invisible while waiting to respawn
