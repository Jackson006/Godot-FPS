extends Spatial

export (int, "full size", "small") var kit_size = 0 setget kit_size_change # The size of the health pickup

# 0 = full size pickup, 1 = small pickup
const HEALTH_AMOUNTS = [70, 30] # The amount of health each pickup in each size contains

const RESPAWN_TIME = 20 # The amount of time, in seconds, it takes for the health pickup to respawn
var respawn_timer = 0 # A variable used to track how long the health pickup has been waiting to respawn

var is_ready = false # A variable to track whether the _ready function has been called or not

func _ready():

	$Holder/Health_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered") # connects the body entered signal from the health pickup trigger to the trigger body entered function

	is_ready = true # let's us use the setget function

	kit_size_change_values(0, false) # 
	kit_size_change_values(1, false)
	kit_size_change_values(kit_size, true)


func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta

		if respawn_timer <= 0:
			kit_size_change_values(kit_size, true)


func kit_size_change(value):
	if is_ready: # checks to see if is_ready is true
		kit_size_change_values(kit_size, false) # dissable kit assigned to kit size using kit size change variables
		kit_size = value # assign kit size a new variable
		kit_size_change_values(kit_size, true) # enable kit size as true
	else:
		kit_size = value # assign kit size as passed


func kit_size_change_values(size, enable):
	if size == 0: # checks to see which size was passed in
		$Holder/Health_Pickup_Trigger/Shape_Kit.disabled = !enable # get the collision shape for the node and disable it based on the passed in argument/variable
		$Holder/Health_Kit.visible = enable # 
	elif size == 1:
		$Holder/Health_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
		$Holder/Health_Kit_Small.visible = enable


func trigger_body_entered(body): 
	if body.has_method("add_health"): # checks whether or not the body that has just entered has a method/function
		body.add_health(HEALTH_AMOUNTS[kit_size]) # Calls add health
		respawn_timer = RESPAWN_TIME # Set's a time for the respawn timer
		kit_size_change_values(kit_size, false) # calls kit_size_change_values
