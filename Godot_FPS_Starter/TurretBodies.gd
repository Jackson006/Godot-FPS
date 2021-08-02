extends StaticBody

export (NodePath) var path_to_turret_root # ecports the path to turret root

func _ready():
	pass # passes the function

func bullet_hit(damage, bullet_hit_pos):
	if path_to_turret_root != null: # Checks if the path to turret root equals null
		get_node(path_to_turret_root).bullet_hit(damage, bullet_hit_pos) # 
