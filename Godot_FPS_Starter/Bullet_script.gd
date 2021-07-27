extends Spatial

var BULLET_SPEED = 70 # the speed at which the bullet travels
var BULLET_DAMAGE = 15 # The damage the bullet causes when it collides

const KILL_TIMER = 4 # How long the bullet can last without colliding 
var timer = 0 # A float tracker which tracks how long the bullet has been alive

var hit_something = false # A boolean for tracking whether or not there had been a collision

func _ready(): # Is called when the collided body enters the area
	$Area.connect("body_entered", self, "collided")


func _physics_process(delta): # get's the bullet's z-axis 
	var forward_dir = global_transform.basis.z.normalized() # the direction of the bullet 
	global_translate(forward_dir * BULLET_SPEED * delta) # The speed of the bullet

	timer += delta # translates the bullet's forward direction
	if timer >= KILL_TIMER:
		queue_free() # deletes the bullet


func collided(body): # cehcks to see whether there has been a collision
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform) # asigns damage

	hit_something = true
	queue_free() # deltes the bullet
