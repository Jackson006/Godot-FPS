extends RigidBody

const GRENADE_DAMAGE = 60 # The amount of damage the grenade causes when it explodes

const GRENADE_TIME = 2 # The amount of time the grenade takes (in seconds) to explode once it's created/thrown
var grenade_timer = 0 #  variable for tracking how long the grenade has been created/thrown

const EXPLOSION_WAIT_TIME = 0.48 # The amount of time needed (in seconds) to wait before we destroy the grenade scene after the explosion
var explosion_wait_timer = 0 # A variable for tracking how much time has passed since the grenade exploded

var rigid_shape # The CollisionShape for the grenade's RigidBody
var grenade_mesh # The MeshInstance for the grenade
var blast_area # The blast Area used to damage things when the grenade explodes
var explosion_particles # The Particles that come out when the grenade explodes

func _ready():
	# class variables
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false
	explosion_particles.one_shot = true

func _process(delta):

	if grenade_timer < GRENADE_TIME: # checks if the grenade timer is less than the grenade time
		grenade_timer += delta # adds delta to the grenade timer
		return
	else:
		if explosion_wait_timer <= 0: # checks if the explosion wait timer is less than or equal to 0
			explosion_particles.emitting = true # is the timer is less than or equal to 0 emmit the particles

			grenade_mesh.visible = false # makes the grenade mesh invisible
			rigid_shape.disabled = true # Disables the shape of the grenade

			mode = RigidBody.MODE_STATIC # Makes it so that the grenade does not move

			var bodies = blast_area.get_overlapping_bodies() # gets all the bodies in the grenade's blast area
			for body in bodies: 
				if body.has_method("bullet_hit"): # if a body has been hit by a grenade
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0))) # makes the body change position because of the grenade's explosion

			# This would be the perfect place to play a sound!

		if explosion_wait_timer < EXPLOSION_WAIT_TIME: # checks to see if the explosion wait timer is less than the explosion wait time
			explosion_wait_timer += delta # adds delta to the explosion wait timer

			if explosion_wait_timer >= EXPLOSION_WAIT_TIME: # checks to see if the explosion wait timer is greater or equal to the wxplosion wait time
				queue_free() # deletes the grenade
