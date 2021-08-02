extends RigidBody

# variables are the same as the regular grenade
const GRENADE_DAMAGE = 40 

const GRENADE_TIME = 3
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.48
var explosion_wait_timer = 0

var attached = false # A variable for tracking whether or not the sticky grenade has attached to a PhysicsBody
var attach_point = null # A variable to hold a Spatial that will be at the position where the sticky grenade collided

var rigid_shape
var grenade_mesh
var blast_area
var explosion_particles

var player_body # The player's KinematicBody

func _ready():
# class variables are the same as the regular grenade
	rigid_shape = $Collision_Shape
	grenade_mesh = $Sticky_Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false
	explosion_particles.one_shot = true

	$Sticky_Area.connect("body_entered", self, "collided_with_body")


func collided_with_body(body):

# Checks to make sure the body it has collided with is not itself
	if body == self:
		return

# Checks to make sure the body it has collided with the player
	if player_body != null:
		if body == player_body:
			return

	if attached == false: # checks to see if the grenade is attacked to something
		attached = true # checks to see if the grenade is attacked to something
		attach_point = Spatial.new() # creates a spatial node 
		body.add_child(attach_point) # makes it the child of the body the sticky grenade has collided with 
		attach_point.global_transform.origin = global_transform.origin # sets the spatial position to the sticky grenade's current location

		rigid_shape.disabled = true # makes it so that the sticky grenade is not moving whatever it collided with

		mode = RigidBody.MODE_STATIC # makes it so that the sticky grenade cannot move 

func _process(delta):
	if attached == true: # checks if the grenade is attachted to something
		if attach_point != null: # makes sure the attached point is not equal to null
			global_transform.origin = attach_point.global_transform.origin # makes the global position of the grenade to whatever it is attached to

	if grenade_timer < GRENADE_TIME: # checks to see if the grenade timer is less than the grenade time
		grenade_timer += delta # adds delta to the grenade timer
		return # returns the value
	else:
		if explosion_wait_timer <= 0: # checks if the explosion wait timer is less than or equal to 0
			explosion_particles.emitting = true # emits the explosion particles

			grenade_mesh.visible = false # makes the grenade invisible
			rigid_shape.disabled = true # Disables the shape of the grenade

			mode = RigidBody.MODE_STATIC # makes it so that the grenade cannot move

			var bodies = blast_area.get_overlapping_bodies() # gets the bodies in the blast
			for body in bodies: # for the things that were hit
				if body.has_method("bullet_hit"): # checks to see if the bodies had been hit
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0))) # assigns damage and changes position of bodies because of the blast

			# This would be the perfect place to play a sound!

		if explosion_wait_timer < EXPLOSION_WAIT_TIME: # checks to see if the explosion wait timer is less than the explosion wait time
				explosion_wait_timer += delta # adds delta to the explosion wait timer

		if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
			if attach_point != null: # checks if the attached point is null
				attach_point.queue_free() # deletes the attached point
				queue_free() # deletes the grenade
