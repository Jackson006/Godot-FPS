extends StaticBody

const TARGET_HEALTH = 40 # The amount of damage needed to break a fully healed target
var current_health = 40 # The amount of health this target currently has

var broken_target_holder #A variable to hold the broken target holder 

# The collision shape for the target.
# NOTE: this is for the whole target, not the pieces of the target.
var target_collision_shape # A variable to hold the collision shape for the non-broken target

const TARGET_RESPAWN_TIME = 14 # The length of time, in seconds, it takes for a target to respawn
var target_respawn_timer = 0 # A variable to track how long a target has been broken

export (PackedScene) var destroyed_target # a packed scene to hold the broken target scene

func _ready():
	broken_target_holder = get_parent().get_node("Broken_Target_Holder") # Assigns the broken target holder 
	target_collision_shape = $Collision_Shape # Assigns the target collision shape


func _physics_process(delta):
	if target_respawn_timer > 0: # Checks to see if the respawn timer is greater than 0
		target_respawn_timer -= delta # subtract delta from the respawn timer

		if target_respawn_timer <= 0: # Checks to see if the respaen timer is 0 or less

			for child in broken_target_holder.get_children(): # Removes all the children from the broken target holder
				child.queue_free()

			target_collision_shape.disabled = false # enables the collision shape
			visible = true # makes the target and all child nodes visible
			current_health = TARGET_HEALTH # resets the target's health


func bullet_hit(damage, bullet_transform):
	current_health -= damage # Reduces the current health of the target based on the damage

# if the current health of the target is less than or = to 0, destroy the target and load a broken target that explodes outward
	if current_health <= 0: 
		var clone = destroyed_target.instance()
		broken_target_holder.add_child(clone)

		for rigid in clone.get_children(): # Checks to see if it is a rigid body node
			if rigid is RigidBody: 
				var center_in_rigid_space = broken_target_holder.global_transform.origin - rigid.global_transform.origin # calclates the center position of the target relative to the child node
				var direction = (rigid.transform.origin - center_in_rigid_space).normalized() # figures out which direction the child node is relative to the center
				# Apply the impulse with some additional force (I find 12 works nicely).
				rigid.apply_impulse(center_in_rigid_space, direction * 12 * damage) # pushes the child from the calculated center, in the direction away from the center

		target_respawn_timer = TARGET_RESPAWN_TIME # sets the target's respawn timer

		target_collision_shape.disabled = true # Makes it take a certain amount of time for the target to respawn
		visible = false # makes the target invisible
